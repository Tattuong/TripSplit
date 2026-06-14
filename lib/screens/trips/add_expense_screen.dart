import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/expense.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/member_avatar.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tripId;

  const AddExpenseScreen({super.key, required this.tripId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _percentCtrls = <String, TextEditingController>{};

  String? _paidById;
  final _splitIds = <String>{};
  String _category = 'food';
  DateTime _date = DateTime.now();
  bool _useCustomSplit = false;

  static const _categories = ['food', 'transport', 'hotel', 'shopping', 'entertainment', 'other'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _percentCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final trips = context.read<TripProvider>();
    final shop = context.read<ShopProvider>();
    final trip = trips.getTrip(widget.tripId);
    if (trip == null) return;

    if (_titleCtrl.text.trim().isEmpty) {
      AppToast.show(context, title: AppStrings.t(context, 'expenseTitleHint'), color: AppColors.warning);
      return;
    }

    final amount = CurrencyFormatter.parseAmount(_amountCtrl.text, trip.currency);
    if (amount == null || amount <= 0) {
      AppToast.show(context, title: AppStrings.t(context, 'enterAmount'), color: AppColors.warning);
      return;
    }

    if (_paidById == null) {
      AppToast.show(context, title: AppStrings.t(context, 'selectPayer'), color: AppColors.warning);
      return;
    }

    if (_splitIds.isEmpty) {
      AppToast.show(context, title: AppStrings.t(context, 'selectSplit'), color: AppColors.warning);
      return;
    }

    Map<String, double>? customSplits;
    if (_useCustomSplit && shop.hasCustomSplit) {
      customSplits = {};
      var total = 0.0;
      for (final id in _splitIds) {
        final pct = double.tryParse(_percentCtrls[id]?.text ?? '') ?? 0;
        customSplits[id] = pct / 100;
        total += pct;
      }
      if ((total - 100).abs() > 0.5) {
        AppToast.show(context, title: AppStrings.t(context, 'percentTotal'), color: AppColors.warning);
        return;
      }
    }

    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      paidById: _paidById!,
      splitAmongIds: _splitIds.toList(),
      customSplits: customSplits,
      category: _category,
      note: shop.hasExpenseNote && _noteCtrl.text.isNotEmpty ? _noteCtrl.text.trim() : null,
      date: _date,
    );

    await trips.addExpense(widget.tripId, expense);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripProvider>();
    final shop = context.watch<ShopProvider>();
    final trip = trips.getTrip(widget.tripId);

    if (trip == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    _paidById ??= trip.members.first.id;
    if (_splitIds.isEmpty) _splitIds.addAll(trip.members.map((m) => m.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'addExpense')),
        actions: [
          TextButton(onPressed: _save, child: Text(AppStrings.t(context, 'save'), style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: AppStrings.t(context, 'expenseTitle'),
              hintText: AppStrings.t(context, 'expenseTitleHint'),
              prefixIcon: const Icon(Icons.receipt_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: CurrencyFormatter.usesDecimals(trip.currency)
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: [
              if (CurrencyFormatter.usesDecimals(trip.currency))
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: AppStrings.t(context, 'amount'),
              prefixIcon: const Icon(Icons.payments_outlined),
              suffixText: CurrencyFormatter.currencyLabel(trip.currency),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.t(context, 'category'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = _category == cat;
              return FilterChip(
                selected: selected,
                label: Text(AppStrings.categoryLabel(context, cat)),
                avatar: Icon(AppStrings.categoryIcon(cat), size: 16),
                onSelected: (_) => setState(() => _category = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.t(context, 'paidBy'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...trip.members.asMap().entries.map((e) {
            final m = e.value;
            final selected = _paidById == m.id;
            return ListTile(
              leading: MemberAvatar(member: m, index: e.key, size: 36, showBorder: selected),
              title: Text(m.name),
              trailing: selected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
              onTap: () => setState(() => _paidById = m.id),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(AppStrings.t(context, 'splitAmong'), style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  if (_splitIds.length == trip.members.length) {
                    _splitIds.clear();
                  } else {
                    _splitIds.addAll(trip.members.map((m) => m.id));
                  }
                }),
                child: Text(AppStrings.t(context, 'selectAll'), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          ...trip.members.asMap().entries.map((e) {
            final m = e.value;
            final selected = _splitIds.contains(m.id);
            return CheckboxListTile(
              value: selected,
              onChanged: (v) => setState(() {
                if (v == true) {
                  _splitIds.add(m.id);
                } else if (_splitIds.length > 1) {
                  _splitIds.remove(m.id);
                }
              }),
              secondary: MemberAvatar(member: m, index: e.key, size: 32),
              title: Text(m.name),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }),
          if (shop.hasCustomSplit) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(AppStrings.t(context, 'customSplit')),
              value: _useCustomSplit,
              onChanged: (v) => setState(() {
                _useCustomSplit = v;
                if (v) {
                  for (final id in _splitIds) {
                    _percentCtrls.putIfAbsent(id, () => TextEditingController(text: '${(100 / _splitIds.length).round()}'));
                  }
                }
              }),
            ),
            if (_useCustomSplit)
              ..._splitIds.map((id) {
                final m = trip.memberById(id)!;
                final idx = trip.members.indexOf(m);
                _percentCtrls.putIfAbsent(id, () => TextEditingController());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      MemberAvatar(member: m, index: idx, size: 28),
                      const SizedBox(width: 10),
                      Expanded(child: Text(m.name)),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _percentCtrls[id],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(suffixText: '%', isDense: true),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ] else
            _LockedBanner(text: AppStrings.t(context, 'customSplitLocked')),
          if (shop.hasExpenseNote) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.t(context, 'note'),
                hintText: AppStrings.t(context, 'noteHint'),
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton(
            onPressed: _save,
            child: Text(AppStrings.t(context, 'save'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  final String text;

  const _LockedBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))),
        ],
      ),
    );
  }
}
