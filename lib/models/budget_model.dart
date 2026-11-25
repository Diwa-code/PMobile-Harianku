import 'category_model.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final double limitAmount;
  final int month;
  final int year;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    int? month,
    int? year,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

enum BudgetStatus { safe, warning, critical }

class BudgetProgress {
  final BudgetModel budget;
  final CategoryModel category;
  final double spentAmount;

  const BudgetProgress({
    required this.budget,
    required this.category,
    required this.spentAmount,
  });

  double get remaining => budget.limitAmount - spentAmount;

  double get percentage =>
      budget.limitAmount > 0 ? (spentAmount / budget.limitAmount) * 100 : 0.0;

  BudgetStatus get status {
    if (percentage < 75) return BudgetStatus.safe;
    if (percentage <= 95) return BudgetStatus.warning;
    return BudgetStatus.critical;
  }
}
