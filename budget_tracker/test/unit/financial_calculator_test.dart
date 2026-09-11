import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/shared/domain/entities/transaction.dart';
import 'package:budget_tracker/shared/domain/entities/enums.dart';
import 'package:budget_tracker/shared/domain/entities/budget.dart';
import 'package:budget_tracker/shared/domain/entities/financial_goal.dart';
import 'package:budget_tracker/shared/domain/entities/recurring_transaction.dart';
import 'package:budget_tracker/shared/domain/services/financial_calculator.dart';

Transaction _txn({
  required TransactionType type,
  required double amount,
  required DateTime date,
  int categoryId = 1,
  int accountId = 1,
}) {
  return Transaction(
    userId: 1,
    accountId: accountId,
    categoryId: categoryId,
    type: type,
    amount: amount,
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  final calculator = const FinancialCalculator();

  group('calculateCurrentBalance', () {
    test('income adds, expense subtracts, transfer nets to zero', () {
      final txns = [
        _txn(type: TransactionType.income, amount: 1000, date: DateTime(2026, 1, 1)),
        _txn(type: TransactionType.expense, amount: 300, date: DateTime(2026, 1, 2)),
        _txn(type: TransactionType.transfer, amount: 200, date: DateTime(2026, 1, 3)),
      ];
      expect(calculator.calculateCurrentBalance(txns), 700);
    });

    test('respects asOfDate cutoff', () {
      final txns = [
        _txn(type: TransactionType.income, amount: 1000, date: DateTime(2026, 1, 1)),
        _txn(type: TransactionType.expense, amount: 300, date: DateTime(2026, 2, 15)),
      ];
      expect(calculator.calculateCurrentBalance(txns, asOfDate: DateTime(2026, 1, 31)), 1000);
    });
  });

  group('calculateMonthlyExpenses', () {
    test('sums only expenses within the given month', () {
      final txns = [
        _txn(type: TransactionType.expense, amount: 100, date: DateTime(2026, 8, 5)),
        _txn(type: TransactionType.expense, amount: 200, date: DateTime(2026, 8, 20)),
        _txn(type: TransactionType.expense, amount: 999, date: DateTime(2026, 7, 20)),
        _txn(type: TransactionType.income, amount: 500, date: DateTime(2026, 8, 1)),
      ];
      expect(calculator.calculateMonthlyExpenses(txns, DateTime(2026, 8, 15)), 300);
    });

    test('filters by categoryId when provided', () {
      final txns = [
        _txn(type: TransactionType.expense, amount: 100, date: DateTime(2026, 8, 5), categoryId: 1),
        _txn(type: TransactionType.expense, amount: 200, date: DateTime(2026, 8, 6), categoryId: 2),
      ];
      expect(calculator.calculateMonthlyExpenses(txns, DateTime(2026, 8, 1), categoryId: 1), 100);
    });
  });

  group('calculateSavingsRate', () {
    test('computes fraction saved', () {
      final txns = [
        _txn(type: TransactionType.income, amount: 1000, date: DateTime(2026, 8, 1)),
        _txn(type: TransactionType.expense, amount: 750, date: DateTime(2026, 8, 10)),
      ];
      expect(calculator.calculateSavingsRate(txns, DateTime(2026, 8, 15)), closeTo(0.25, 0.0001));
    });

    test('returns 0 when there is no income, rather than dividing by zero', () {
      final txns = [_txn(type: TransactionType.expense, amount: 500, date: DateTime(2026, 8, 10))];
      expect(calculator.calculateSavingsRate(txns, DateTime(2026, 8, 15)), 0);
    });
  });

  group('calculateBudgetUsage / percentage', () {
    test('flags overspending with percentage > 1.0', () {
      final budget = Budget(
        userId: 1,
        name: 'August',
        type: BudgetType.monthly,
        periodStart: DateTime(2026, 8, 1),
        periodEnd: DateTime(2026, 8, 31),
        totalBudget: 1000,
        strategy: BudgetStrategy.zeroBased,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
      );
      final txns = [_txn(type: TransactionType.expense, amount: 1200, date: DateTime(2026, 8, 10))];
      expect(calculator.calculateBudgetPercentage(budget, txns), closeTo(1.2, 0.0001));
      expect(calculator.calculateBudgetRemaining(budget, txns), -200);
    });
  });

  group('calculateAffordableSpending', () {
    test('accounts for upcoming recurring expenses before approving a purchase', () {
      final recurring = [
        RecurringTransaction(
          userId: 1,
          accountId: 1,
          categoryId: 1,
          type: TransactionType.expense,
          amount: 5000,
          description: 'Rent',
          frequency: RecurringFrequency.monthly,
          startDate: DateTime(2026, 8, 1),
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 1),
        ),
      ];

      final result = calculator.calculateAffordableSpending(
        currentBalance: 6000,
        recurringExpenses: recurring,
        proposedAmount: 2000,
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
      );

      // 6000 - 5000 (rent) - 2000 (proposed) = -1000 -> cannot afford
      expect(result.canAfford, isFalse);
      expect(result.projectedBalanceAfterPurchase, -1000);
    });

    test('approves when balance covers recurring expenses plus the purchase', () {
      final recurring = <RecurringTransaction>[];
      final result = calculator.calculateAffordableSpending(
        currentBalance: 5000,
        recurringExpenses: recurring,
        proposedAmount: 2000,
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 31),
      );
      expect(result.canAfford, isTrue);
      expect(result.projectedBalanceAfterPurchase, 3000);
    });
  });

  group('goal calculations', () {
    test('calculateGoalCompletionDate projects forward by months needed', () {
      final goal = FinancialGoal(
        userId: 1,
        name: 'Emergency Fund',
        targetAmount: 10000,
        currentAmount: 4000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      // 6000 remaining / 2000 per month = 3 months
      final completion = calculator.calculateGoalCompletionDate(goal, 2000, from: DateTime(2026, 8, 1));
      expect(completion, DateTime(2026, 11, 1));
    });

    test('calculateGoalCompletionDate returns null for non-positive contribution', () {
      final goal = FinancialGoal(
        userId: 1,
        name: 'Vacation',
        targetAmount: 5000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(calculator.calculateGoalCompletionDate(goal, 0, from: DateTime(2026, 8, 1)), isNull);
    });
  });
}
