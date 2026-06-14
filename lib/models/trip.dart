import 'expense.dart';
import 'member.dart';

class Trip {
  final String id;
  final String name;
  final String currency;
  final List<Member> members;
  final List<Expense> expenses;
  final DateTime createdAt;
  final String? note;

  const Trip({
    required this.id,
    required this.name,
    this.currency = 'VND',
    required this.members,
    required this.expenses,
    required this.createdAt,
    this.note,
  });

  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Member? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'currency': currency,
        'members': members.map((m) => m.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        if (note != null) 'note': note,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        name: json['name'] as String,
        currency: json['currency'] as String? ?? 'VND',
        members: (json['members'] as List).map((m) => Member.fromJson(m as Map<String, dynamic>)).toList(),
        expenses: (json['expenses'] as List).map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        note: json['note'] as String?,
      );

  Trip copyWith({
    String? name,
    String? currency,
    List<Member>? members,
    List<Expense>? expenses,
    String? note,
  }) =>
      Trip(
        id: id,
        name: name ?? this.name,
        currency: currency ?? this.currency,
        members: members ?? this.members,
        expenses: expenses ?? this.expenses,
        createdAt: createdAt,
        note: note ?? this.note,
      );
}
