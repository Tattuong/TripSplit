import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/storage_service.dart';
import '../models/expense.dart';
import '../models/member.dart';
import '../models/trip.dart';

class TripProvider extends ChangeNotifier {
  static const _tripsKey = 'ts_trips';
  static const _uuid = Uuid();

  List<Trip> _trips = [];
  bool _isLoading = true;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await StorageService.instance.getString(_tripsKey);
    if (raw == null || raw.isEmpty) {
      _trips = [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _trips = list.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Trip load error: $e');
      _trips = [];
    }
  }

  Future<void> _save() async {
    final encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await StorageService.instance.saveString(_tripsKey, encoded);
  }

  Trip? getTrip(String id) {
    for (final t in _trips) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool canCreateTrip({required bool hasUnlimited}) {
    if (hasUnlimited) return true;
    return _trips.length < IapConstants.freeTripLimit;
  }

  Future<Trip?> createTrip({
    required String name,
    required List<String> memberNames,
    String currency = 'VND',
    String? note,
    required bool hasUnlimited,
    required bool hasMultiCurrency,
  }) async {
    if (!canCreateTrip(hasUnlimited: hasUnlimited)) return null;

    final members = memberNames
        .where((n) => n.trim().isNotEmpty)
        .map((n) => Member(id: _uuid.v4(), name: n.trim()))
        .toList();

    if (members.length < 2) return null;

    final trip = Trip(
      id: _uuid.v4(),
      name: name.trim(),
      currency: hasMultiCurrency ? currency : 'VND',
      members: members,
      expenses: [],
      createdAt: DateTime.now(),
      note: note?.trim(),
    );

    _trips.insert(0, trip);
    await _save();
    notifyListeners();
    return trip;
  }

  Future<void> updateTrip(Trip trip) async {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index < 0) return;
    _trips[index] = trip;
    await _save();
    notifyListeners();
  }

  Future<void> deleteTrip(String id) async {
    _trips.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addExpense(String tripId, Expense expense) async {
    final trip = getTrip(tripId);
    if (trip == null) return;
    await updateTrip(trip.copyWith(expenses: [...trip.expenses, expense]));
  }

  Future<void> removeExpense(String tripId, String expenseId) async {
    final trip = getTrip(tripId);
    if (trip == null) return;
    await updateTrip(trip.copyWith(
      expenses: trip.expenses.where((e) => e.id != expenseId).toList(),
    ));
  }

  Future<void> addMember(String tripId, String name) async {
    final trip = getTrip(tripId);
    if (trip == null || name.trim().isEmpty) return;
    final member = Member(id: _uuid.v4(), name: name.trim());
    await updateTrip(trip.copyWith(members: [...trip.members, member]));
  }

  Future<void> removeMember(String tripId, String memberId) async {
    final trip = getTrip(tripId);
    if (trip == null || trip.members.length <= 2) return;
    final hasExpenses = trip.expenses.any(
      (e) => e.paidById == memberId || e.splitAmongIds.contains(memberId),
    );
    if (hasExpenses) return;
    await updateTrip(trip.copyWith(
      members: trip.members.where((m) => m.id != memberId).toList(),
    ));
  }

  String exportTripJson(String tripId) {
    final trip = getTrip(tripId);
    if (trip == null) return '';
    return const JsonEncoder.withIndent('  ').convert(trip.toJson());
  }

  String exportAllJson() {
    return const JsonEncoder.withIndent('  ').convert(_trips.map((t) => t.toJson()).toList());
  }

  Future<bool> importFromJson(String raw) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _trips.insert(0, Trip.fromJson(decoded));
      } else if (decoded is List) {
        for (final item in decoded) {
          _trips.add(Trip.fromJson(item as Map<String, dynamic>));
        }
      } else {
        return false;
      }
      _trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _save();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }
}
