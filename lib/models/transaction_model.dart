class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' atau 'expense'
  final String categoryId;
  final String date; // ISO-8601
  final String? note;
  final String source; // 'manual' atau 'ai'
  final String createdAt; // ISO-8601

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    required this.source,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date,
      'note': note,
      'source': source,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as String,
      date: map['date'] as String,
      note: map['note'] as String?,
      source: map['source'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? categoryId,
    String? date,
    String? note,
    String? source,
    String? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
