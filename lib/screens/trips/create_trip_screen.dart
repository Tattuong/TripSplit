import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/app_toast.dart';
import 'trip_detail_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _memberCtrls = [TextEditingController(), TextEditingController()];
  String _currency = 'VND';

  static const _currencies = ['VND', 'USD', 'EUR', 'THB', 'JPY'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _memberCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final shop = context.read<ShopProvider>();
    final trips = context.read<TripProvider>();

    if (_nameCtrl.text.trim().isEmpty) {
      AppToast.show(context, title: AppStrings.t(context, 'enterTripName'), icon: Icons.warning_amber_rounded, color: AppColors.warning);
      return;
    }

    final names = _memberCtrls.map((c) => c.text.trim()).where((n) => n.isNotEmpty).toList();
    if (names.length < 2) {
      AppToast.show(context, title: AppStrings.t(context, 'minMembers'), icon: Icons.warning_amber_rounded, color: AppColors.warning);
      return;
    }

    final trip = await trips.createTrip(
      name: _nameCtrl.text,
      memberNames: names,
      currency: _currency,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      hasUnlimited: shop.hasUnlimitedTrips,
      hasMultiCurrency: shop.hasMultiCurrency,
    );

    if (!mounted) return;
    if (trip == null) {
      AppToast.show(context, title: AppStrings.t(context, 'tripLimitReached'), color: AppColors.warning);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'createTrip')),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(AppStrings.t(context, 'save'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: AppStrings.t(context, 'tripName'),
              hintText: AppStrings.t(context, 'tripNameHint'),
              prefixIcon: const Icon(Icons.trip_origin),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          if (shop.hasMultiCurrency)
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'currency')),
              items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'VND'),
            )
          else
            _LockedFeature(
              label: AppStrings.t(context, 'currency'),
              lockedText: AppStrings.t(context, 'multiCurrencyLocked'),
            ),
          const SizedBox(height: 24),
          Text(AppStrings.t(context, 'members'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (var i = 0; i < _memberCtrls.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _memberCtrls[i],
                decoration: InputDecoration(
                  hintText: '${AppStrings.t(context, 'memberNameHint')} ${i + 1}',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.memberPalette[i % AppColors.memberPalette.length]),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _memberCtrls.add(TextEditingController())),
            icon: const Icon(Icons.person_add_outlined),
            label: Text(AppStrings.t(context, 'addMember')),
          ),
          const SizedBox(height: 16),
          if (shop.hasExpenseNote)
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.t(context, 'tripNote'),
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            )
          else
            _LockedFeature(
              label: AppStrings.t(context, 'note'),
              lockedText: AppStrings.t(context, 'expenseNoteLocked'),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton(
            onPressed: _save,
            child: Text(AppStrings.t(context, 'createTrip'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _LockedFeature extends StatelessWidget {
  final String label;
  final String lockedText;

  const _LockedFeature({required this.label, required this.lockedText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(lockedText, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
