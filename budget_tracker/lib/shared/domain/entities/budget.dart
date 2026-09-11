import "package:equatable/equatable.dart";
import "enums.dart";

class Budget extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final BudgetType type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalBudget;
  final BudgetStrategy strategy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.totalBudget,
    required this.strategy,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool coversDate(DateTime date) => !date.isBefore(periodStart) && !date.isAfter(periodEnd);

  Budget copyWith({
    int? id,
    String? name,
    BudgetType? type,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalBudget,
    BudgetStrategy? strategy,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalBudget: totalBudget ?? this.totalBudget,
      strategy: strategy ?? this.strategy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, type, periodStart, periodEnd, totalBudget, strategy, isActive];
}

class BudgetItem extends Equatable {
  final int? id;
  final int budgetId;
  final int categoryId;
  final double amount;
  final double? percentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetItem({
    this.id,
    required this.budgetId,
    required this.categoryId,
    required this.amount,
    this.percentage,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetItem copyWith({int? id, double? amount, double? percentage, DateTime? updatedAt}) {
    return BudgetItem(
      id: id ?? this.id,
      budgetId: budgetId,
      categoryId: categoryId,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, budgetId, categoryId, amount, percentage];
}
