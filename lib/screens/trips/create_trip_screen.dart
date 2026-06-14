import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/member.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/app_toast.dart';
import 'trip_detail_screen.dart';

class _MemberField {
  final String? id;
  final TextEditingController controller;

  _MemberField({this.id, required this.controller});
}

class CreateTripScreen extends StatefulWidget {
  final String? tripId;

  const CreateTripScreen({super.key, this.tripId});

  bool get isEditing => tripId != null;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  static const _uuid = Uuid();
  static const _currencies = ['VND', 'USD', 'EUR', 'THB', 'JPY'];

  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _memberFields = <_MemberField>[];
  String _currency = 'USD';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrip());
  }

  void _loadTrip() {
    if (_initialized) return;
    _initialized = true;

    if (!widget.isEditing) {
      _currency = CurrencyFormatter.defaultForLocale(AppStrings.languageCodeOf(context));
      _memberFields.addAll([
        _MemberField(controller: TextEditingController()),
        _MemberField(controller: TextEditingController()),
      ]);
      setState(() {});
      return;
    }

    final trip = context.read<TripProvider>().getTrip(widget.tripId!);
    if (trip == null) return;

    _nameCtrl.text = trip.name;
    _noteCtrl.text = trip.note ?? '';
    _currency = trip.currency;
    _memberFields.addAll(
      trip.members.map((m) => _MemberField(id: m.id, controller: TextEditingController(text: m.name))),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    for (final f in _memberFields) {
      f.controller.dispose();
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

    final members = <Member>[];
    for (final field in _memberFields) {
      final name = field.controller.text.trim();
      if (name.isEmpty) continue;
      members.add(Member(id: field.id ?? _uuid.v4(), name: name));
    }

    if (members.length < 2) {
      AppToast.show(context, title: AppStrings.t(context, 'minMembers'), icon: Icons.warning_amber_rounded, color: AppColors.warning);
      return;
    }

    if (widget.isEditing) {
      final ok = await trips.updateTripDetails(
        tripId: widget.tripId!,
        name: _nameCtrl.text,
        members: members,
        currency: _currency,
        note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
        hasMultiCurrency: shop.hasMultiCurrency,
      );
      if (!mounted) return;
      if (ok) {
        AppToast.show(context, title: AppStrings.t(context, 'tripUpdated'));
        Navigator.pop(context);
      }
      return;
    }

    final trip = await trips.createTrip(
      name: _nameCtrl.text,
      memberNames: members.map((m) => m.name).toList(),
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

  void _removeMember(int index) {
    final trips = context.read<TripProvider>();
    final field = _memberFields[index];

    if (widget.isEditing && field.id != null) {
      final trip = trips.getTrip(widget.tripId!);
      if (trip != null && trips.memberHasExpenses(trip, field.id!)) {
        AppToast.show(context, title: AppStrings.t(context, 'cannotRemoveMember'), color: AppColors.warning);
        return;
      }
    }

    if (_memberFields.length <= 2) return;
    setState(() {
      field.controller.dispose();
      _memberFields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isEditing = widget.isEditing;
    final trip = isEditing ? context.watch<TripProvider>().getTrip(widget.tripId!) : null;

    if (isEditing && trip == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t(context, isEditing ? 'editTrip' : 'createTrip')),
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
          if (shop.hasMultiCurrency && (!isEditing || trip!.expenses.isEmpty))
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'currency')),
              items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'VND'),
            )
          else if (!shop.hasMultiCurrency)
            _LockedFeature(
              label: AppStrings.t(context, 'currency'),
              lockedText: '${AppStrings.t(context, 'multiCurrencyLocked')} · $_currency',
            )
          else if (isEditing)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.currency_exchange_outlined),
              title: Text(AppStrings.t(context, 'currency')),
              subtitle: Text(AppStrings.t(context, 'currencyLockedHasExpenses')),
              trailing: Text(trip!.currency, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          const SizedBox(height: 24),
          Text(AppStrings.t(context, 'members'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (var i = 0; i < _memberFields.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberFields[i].controller,
                      decoration: InputDecoration(
                        hintText: '${AppStrings.t(context, 'memberNameHint')} ${i + 1}',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.memberPalette[i % AppColors.memberPalette.length]),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  if (_memberFields.length > 2)
                    IconButton(
                      onPressed: () => _removeMember(i),
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                    ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _memberFields.add(_MemberField(controller: TextEditingController()))),
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
            child: Text(
              AppStrings.t(context, isEditing ? 'save' : 'createTrip'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
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
