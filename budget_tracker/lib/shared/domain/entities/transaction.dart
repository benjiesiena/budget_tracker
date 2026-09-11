import 'package:equatable/equatable.dart';
import 'enums.dart';

/// A single money movement. This is the atomic unit the entire app is built
/// on — balances, budgets, goals, and every AI tool ultimately derive from
/// aggregations over this table.
class Transaction extends Equatable {
  final int? id;
  final int userId;
  final int accountId;
  final int categoryId;
  final TransactionType type;
  final double amount; // always positive; sign is implied by `type`
  final String? description;
  final String? notes;
  final DateTime date;
  final List<String> tags;
  final bool isRecurring;
  final int? recurringTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    this.notes,
    required this.date,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringTransactionId,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(amount >= 0, 'Transaction.amount must be non-negative; use `type` for sign');

  /// Signed amount for balance math: expenses subtract, income adds,
  /// transfers net to zero at the user level (they move money between
  /// the user's own accounts).
  double get signedAmount => switch (type) {
        TransactionType.expense => -amount,
        TransactionType.income => amount,
        TransactionType.transfer => 0,
      };

  Transaction copyWith({
    int? id,
    int? userId,
    int? accountId,
    int? categoryId,
    TransactionType? type,
    double? amount,
    String? description,
    String? notes,
    DateTime? date,
    List<String>? tags,
    bool? isRecurring,
    int? recurringTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringTransactionId: recurringTransactionId ?? this.recurringTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        accountId,
        categoryId,
        type,
        amount,
        description,
        notes,
        date,
        tags,
        isRecurring,
        recurringTransactionId,
      ];
}
