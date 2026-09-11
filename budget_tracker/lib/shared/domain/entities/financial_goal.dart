import "package:equatable/equatable.dart";

class FinancialGoal extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final int? categoryId;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialGoal({
    this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.categoryId,
    this.icon,
    this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingAmount => (targetAmount - currentAmount).clamp(0, targetAmount);

  double get progressPercentage =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  bool get isComplete => currentAmount >= targetAmount;

  FinancialGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    int? categoryId,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      userId: userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      categoryId: categoryId ?? this.categoryId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, targetAmount, currentAmount, targetDate, isActive];
}
