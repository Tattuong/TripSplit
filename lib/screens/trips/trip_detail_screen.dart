import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/settlement_service.dart';
import '../../models/expense.dart';
import '../../models/trip.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/member_avatar.dart';
import 'add_expense_screen.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final shop = context.watch<ShopProvider>();
    final trip = trips.getTrip(tripId);

    if (trip == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Icon(Icons.error_outline)));
    }

    final settlement = SettlementService.calculate(trip);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (shop.hasExportBackup)
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => _export(context, trips),
            )
          else
            IconButton(
              icon: const Icon(Icons.lock_outline),
              onPressed: () => AppToast.show(context, title: AppStrings.t(context, 'exportLocked'), color: AppColors.warning),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          _SummaryCard(trip: trip, settlement: settlement),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(AppStrings.t(context, 'expenses'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '${trip.expenses.length}',
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (trip.expenses.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(AppStrings.t(context, 'noExpenses'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(AppStrings.t(context, 'noExpensesDesc'), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            )
          else
            ...trip.expenses.reversed.map((e) => _ExpenseTile(trip: trip, expense: e)),
          const SizedBox(height: 24),
          _SettlementSection(trip: trip, settlement: settlement),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpenseScreen(tripId: tripId)),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.t(context, 'addExpense')),
      ),
    );
  }

  void _export(BuildContext context, TripProvider trips) {
    final json = trips.exportTripJson(tripId);
    Clipboard.setData(ClipboardData(text: json));
    AppToast.show(context, title: AppStrings.t(context, 'exportSuccess'));
  }
}

class _SummaryCard extends StatelessWidget {
  final Trip trip;
  final SettlementResult settlement;

  const _SummaryCard({required this.trip, required this.settlement});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: shop.activeBackground.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < trip.members.length && i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                MemberAvatar(member: trip.members[i], index: i, size: 36),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatAmount(settlement.totalExpenses, trip.currency),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          Text(
            AppStrings.t(context, 'totalSpent'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double amount, String currency) {
    if (currency == 'VND') {
      return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    }
    return '${amount.toStringAsFixed(2)} $currency';
  }
}

class _ExpenseTile extends StatelessWidget {
  final Trip trip;
  final Expense expense;

  const _ExpenseTile({required this.trip, required this.expense});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payer = trip.memberById(expense.paidById);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TripProvider>().removeExpense(trip.id, expense.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(AppStrings.categoryIcon(expense.category), color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    '${payer?.name ?? '?'} · ${DateFormat.yMMMd().format(expense.date)}',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Text(expense.note!, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Text(
              _SummaryCard._formatAmount(expense.amount, trip.currency),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementSection extends StatefulWidget {
  final Trip trip;
  final SettlementResult settlement;

  const _SettlementSection({required this.trip, required this.settlement});

  @override
  State<_SettlementSection> createState() => _SettlementSectionState();
}

class _SettlementSectionState extends State<_SettlementSection> {
  bool _rewarded = false;

  @override
  void initState() {
    super.initState();
    _grantReward();
  }

  Future<void> _grantReward() async {
    if (_rewarded) return;
    final shop = context.read<ShopProvider>();
    final ok = await shop.rewardForSettlement();
    if (ok && mounted) {
      _rewarded = true;
      AppToast.show(
        context,
        title: AppStrings.t(context, 'settlementReward', {'count': '8'}),
        icon: Icons.monetization_on_rounded,
        color: AppColors.coin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final s = widget.settlement;
    final trip = widget.trip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppStrings.t(context, 'settlementTitle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (shop.hasShareSettlement)
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => Share.share(SettlementService.formatShareText(s, trip)),
              )
            else
              IconButton(
                icon: const Icon(Icons.lock_outline),
                onPressed: () => AppToast.show(context, title: AppStrings.t(context, 'shareLocked'), color: AppColors.warning),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (s.transfers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.celebration_outlined, color: AppColors.success, size: 36),
                const SizedBox(height: 8),
                Text(AppStrings.t(context, 'everyoneSettled'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.success)),
                Text(AppStrings.t(context, 'everyoneSettledDesc'), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          )
        else
          ...s.transfers.map((t) => _TransferCard(transfer: t, currency: trip.currency)),
        const SizedBox(height: 16),
        Text(AppStrings.t(context, 'balance'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        ...s.balances.where((b) => b.balance.abs() > 0.01).map((b) {
          final idx = trip.members.indexOf(b.member);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                MemberAvatar(member: b.member, index: idx, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text(b.member.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Text(
                  '${b.balance > 0 ? '+' : ''}${_SummaryCard._formatAmount(b.balance, trip.currency)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: b.balance > 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TransferCard extends StatelessWidget {
  final PaymentTransfer transfer;
  final String currency;

  const _TransferCard({required this.transfer, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.accent.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(transfer.from.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Column(
            children: [
              const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 18),
              Text(
                _SummaryCard._formatAmount(transfer.amount, currency),
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13),
              ),
            ],
          ),
          Expanded(
            child: Text(transfer.to.name, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
