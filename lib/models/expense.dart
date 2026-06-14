class Expense {
  final String id;
  final String title;
  final double amount;
  final String paidById;
  final List<String> splitAmongIds;
  final Map<String, double>? customSplits;
  final String category;
  final String? note;
  final DateTime date;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidById,
    required this.splitAmongIds,
    this.customSplits,
    this.category = 'other',
    this.note,
    required this.date,
  });

  bool get hasCustomSplit => customSplits != null && customSplits!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'paidById': paidById,
        'splitAmongIds': splitAmongIds,
        if (customSplits != null) 'customSplits': customSplits,
        'category': category,
        if (note != null) 'note': note,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidById: json['paidById'] as String,
        splitAmongIds: (json['splitAmongIds'] as List).cast<String>(),
        customSplits: json['customSplits'] != null
            ? (json['customSplits'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))
            : null,
        category: json['category'] as String? ?? 'other',
        note: json['note'] as String?,
        date: DateTime.parse(json['date'] as String),
      );

  Expense copyWith({
    String? title,
    double? amount,
    String? paidById,
    List<String>? splitAmongIds,
    Map<String, double>? customSplits,
    String? category,
    String? note,
    DateTime? date,
  }) =>
      Expense(
        id: id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        paidById: paidById ?? this.paidById,
        splitAmongIds: splitAmongIds ?? this.splitAmongIds,
        customSplits: customSplits ?? this.customSplits,
        category: category ?? this.category,
        note: note ?? this.note,
        date: date ?? this.date,
      );
}
