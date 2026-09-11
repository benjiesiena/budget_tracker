import "package:equatable/equatable.dart";
import "enums.dart";

class RecurringTransaction extends Equatable {
  final int? id;
  final int userId;
  final int accountId;
  final int categoryId;
  final TransactionType type;
  final double amount;
  final String description;
  final RecurringFrequency frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastProcessedDate;
  final DateTime? nextDueDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    this.lastProcessedDate,
    this.nextDueDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computes the next occurrence strictly after [after]. Deterministic and
  /// pure — no wall-clock reads — so it is unit-testable and safe for the
  /// AI's calculate_cashflow_forecast tool to call repeatedly.
  DateTime nextOccurrence(DateTime after) {
    DateTime candidate = lastProcessedDate ?? startDate;
    while (!candidate.isAfter(after)) {
      candidate = _advance(candidate);
    }
    return candidate;
  }

  DateTime _advance(DateTime date) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return date.add(Duration(days: interval));
      case RecurringFrequency.weekly:
        return date.add(Duration(days: 7 * interval));
      case RecurringFrequency.biweekly:
        return date.add(Duration(days: 14 * interval));
      case RecurringFrequency.monthly:
        final m = date.month - 1 + interval;
        return DateTime(date.year + m ~/ 12, m % 12 + 1, date.day);
      case RecurringFrequency.quarterly:
        final m = date.month - 1 + (3 * interval);
        return DateTime(date.year + m ~/ 12, m % 12 + 1, date.day);
      case RecurringFrequency.yearly:
        return DateTime(date.year + interval, date.month, date.day);
    }
  }

  /// All occurrences in [start, end], inclusive. Used to project recurring
  /// expenses/income into cash-flow forecasts without writing rows to the DB.
  List<DateTime> occurrencesBetween(DateTime start, DateTime end) {
    if (!isActive) return [];
    final occurrences = <DateTime>[];
    DateTime cursor = startDate;
    while (cursor.isBefore(start)) {
      cursor = _advance(cursor);
    }
    while (!cursor.isAfter(end)) {
      if (endDate != null && cursor.isAfter(endDate!)) break;
      occurrences.add(cursor);
      cursor = _advance(cursor);
    }
    return occurrences;
  }

  RecurringTransaction copyWith({
    int? id,
    double? amount,
    String? description,
    RecurringFrequency? frequency,
    int? interval,
    DateTime? endDate,
    DateTime? lastProcessedDate,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, accountId, categoryId, type, amount, frequency, interval, startDate, isActive];
}
