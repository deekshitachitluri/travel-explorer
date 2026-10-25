class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String category; // Accommodation, Food, Transport, Activities, Shopping, Miscellaneous
  final DateTime date;
  final String? notes;

  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    tripId: json['tripId'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    date: DateTime.parse(json['date'] as String),
    notes: json['notes'] as String?,
  );
}
