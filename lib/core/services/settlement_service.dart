import '../../models/expense.dart';
import '../../models/member.dart';
import '../../models/trip.dart';

class MemberBalance {
  final Member member;
  final double balance;

  const MemberBalance({required this.member, required this.balance});

  bool get isCreditor => balance > 0.01;
  bool get isDebtor => balance < -0.01;
}

class PaymentTransfer {
  final Member from;
  final Member to;
  final double amount;

  const PaymentTransfer({required this.from, required this.to, required this.amount});
}

class SettlementResult {
  final List<MemberBalance> balances;
  final List<PaymentTransfer> transfers;
  final double totalExpenses;

  const SettlementResult({
    required this.balances,
    required this.transfers,
    required this.totalExpenses,
  });

  bool get isSettled => transfers.isEmpty && balances.every((b) => b.balance.abs() < 0.01);
}

class SettlementService {
  SettlementService._();

  static SettlementResult calculate(Trip trip) {
    final balanceMap = <String, double>{};
    for (final m in trip.members) {
      balanceMap[m.id] = 0;
    }

    for (final expense in trip.expenses) {
      _applyExpense(balanceMap, expense);
    }

    final balances = trip.members
        .map((m) => MemberBalance(member: m, balance: balanceMap[m.id] ?? 0))
        .toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    final transfers = _minimizeTransfers(balances, trip);

    return SettlementResult(
      balances: balances,
      transfers: transfers,
      totalExpenses: trip.totalSpent,
    );
  }

  static void _applyExpense(Map<String, double> balanceMap, Expense expense) {
    final participants = expense.splitAmongIds.where(balanceMap.containsKey).toList();
    if (participants.isEmpty) return;

    balanceMap[expense.paidById] = (balanceMap[expense.paidById] ?? 0) + expense.amount;

    if (expense.hasCustomSplit) {
      for (final id in participants) {
        final share = expense.customSplits![id] ?? 0;
        balanceMap[id] = (balanceMap[id] ?? 0) - expense.amount * share;
      }
    } else {
      final share = expense.amount / participants.length;
      for (final id in participants) {
        balanceMap[id] = (balanceMap[id] ?? 0) - share;
      }
    }
  }

  static List<PaymentTransfer> _minimizeTransfers(List<MemberBalance> balances, Trip trip) {
    final creditors = balances
        .where((b) => b.isCreditor)
        .map((b) => _MutableBalance(b.member, b.balance))
        .toList();
    final debtors = balances
        .where((b) => b.isDebtor)
        .map((b) => _MutableBalance(b.member, -b.balance))
        .toList();

    final transfers = <PaymentTransfer>[];

    var ci = 0;
    var di = 0;
    while (ci < creditors.length && di < debtors.length) {
      final creditor = creditors[ci];
      final debtor = debtors[di];
      final amount = creditor.amount < debtor.amount ? creditor.amount : debtor.amount;

      if (amount > 0.01) {
        transfers.add(PaymentTransfer(from: debtor.member, to: creditor.member, amount: amount));
        creditor.amount -= amount;
        debtor.amount -= amount;
      }

      if (creditor.amount < 0.01) ci++;
      if (debtor.amount < 0.01) di++;
    }

    return transfers;
  }

  static String formatShareText(SettlementResult result, Trip trip, {bool includeDetails = true}) {
    final buf = StringBuffer();
    buf.writeln('${trip.name} — TripSplit');
    buf.writeln('Total: ${_formatAmount(result.totalExpenses, trip.currency)}');
    buf.writeln('');

    if (result.transfers.isEmpty) {
      buf.writeln('Everyone is settled!');
    } else {
      buf.writeln('Payments:');
      for (final t in result.transfers) {
        buf.writeln('${t.from.name} → ${t.to.name}: ${_formatAmount(t.amount, trip.currency)}');
      }
    }

    if (includeDetails) {
      buf.writeln('');
      buf.writeln('Balances:');
      for (final b in result.balances) {
        if (b.balance.abs() < 0.01) continue;
        final sign = b.balance > 0 ? '+' : '';
        buf.writeln('${b.member.name}: $sign${_formatAmount(b.balance, trip.currency)}');
      }
    }

    return buf.toString().trim();
  }

  static String _formatAmount(double amount, String currency) {
    final abs = amount.abs();
    if (currency == 'VND') {
      return '${abs.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    }
    return '${abs.toStringAsFixed(2)} $currency';
  }
}

class _MutableBalance {
  final Member member;
  double amount;

  _MutableBalance(this.member, this.amount);
}
