import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/shared/domain/entities/transaction.dart';
import 'package:budget_tracker/shared/domain/entities/account.dart';
import 'package:budget_tracker/shared/domain/entities/enums.dart';
import 'package:budget_tracker/shared/domain/entities/budget.dart';
import 'package:budget_tracker/shared/domain/entities/financial_goal.dart';
import 'package:budget_tracker/shared/domain/entities/recurring_transaction.dart';
import 'package:budget_tracker/shared/domain/repositories/transaction_repository.dart';
import 'package:budget_tracker/shared/domain/repositories/account_repository.dart';
import 'package:budget_tracker/shared/domain/repositories/budget_repository.dart';
import 'package:budget_tracker/shared/domain/repositories/goal_repository.dart';
import 'package:budget_tracker/shared/domain/repositories/recurring_transaction_repository.dart';
import 'package:budget_tracker/infrastructure/ai/tools/financial_tools_registry.dart';
import 'package:budget_tracker/infrastructure/ai/tools/ai_tool.dart';

/// Minimal in-memory fakes. Kept in this test file (not shared/test-utils)
/// since they're intentionally the simplest possible implementation of each
/// interface — exactly what a tool-level unit test needs and nothing more.

class FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> data;
  FakeTransactionRepository(this.data);

  @override
  Future<Transaction> create(Transaction t) async => t;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<List<Transaction>> getAllForUser(int userId) async => data;
  @override
  Future<Transaction?> getById(int id) async => null;
  @override
  Future<List<Transaction>> search(int userId, String query) async =>
      data.where((t) => (t.description ?? '').contains(query)).toList();
  @override
  Future<Transaction> update(Transaction t) async => t;
}

class FakeAccountRepository implements AccountRepository {
  @override
  Future<Account> create(Account a) async => a;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<List<Account>> getAllForUser(int userId, {bool activeOnly = true}) async => [];
  @override
  Future<Account?> getById(int id) async => null;
  @override
  Future<Account> update(Account a) async => a;
}

class FakeBudgetRepository implements BudgetRepository {
  Budget? active;
  List<BudgetItem> items = [];
  FakeBudgetRepository({this.active});

  @override
  Future<Budget> create(Budget b, List<BudgetItem> i) async => b;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<Budget?> getActiveForDate(int userId, DateTime date) async => active;
  @override
  Future<List<Budget>> getAllForUser(int userId) async => active != null ? [active!] : [];
  @override
  Future<List<BudgetItem>> getItemsForBudget(int budgetId) async => items;
  @override
  Future<Budget> update(Budget b) async => b;
  @override
  Future<BudgetItem> upsertItem(BudgetItem item) async => item;
}

class FakeGoalRepository implements GoalRepository {
  final List<FinancialGoal> data;
  FakeGoalRepository(this.data);

  @override
  Future<FinancialGoal> create(FinancialGoal g) async => g;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<List<FinancialGoal>> getAllForUser(int userId, {bool activeOnly = true}) async => data;
  @override
  Future<FinancialGoal?> getById(int id) async => data.where((g) => g.id == id).firstOrNull;
  @override
  Future<FinancialGoal> update(FinancialGoal g) async => g;
}

class FakeRecurringRepository implements RecurringTransactionRepository {
  final List<RecurringTransaction> data;
  FakeRecurringRepository(this.data);

  @override
  Future<RecurringTransaction> create(RecurringTransaction r) async => r;
  @override
  Future<void> delete(int id) async {}
  @override
  Future<List<RecurringTransaction>> getAllForUser(int userId, {bool activeOnly = true}) async => data;
  @override
  Future<RecurringTransaction> update(RecurringTransaction r) async => r;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

AITool _find(List<AITool> tools, String name) => tools.firstWhere((t) => t.name == name);

void main() {
  group('get_current_balance', () {
    test('fails gracefully instead of fabricating a number when there is no data', () async {
      final registry = FinancialToolsRegistry(
        userId: 1,
        transactionRepository: FakeTransactionRepository([]),
        accountRepository: FakeAccountRepository(),
        budgetRepository: FakeBudgetRepository(),
        goalRepository: FakeGoalRepository([]),
        recurringRepository: FakeRecurringRepository([]),
      );

      final result = await _find(registry.buildTools(), 'get_current_balance').execute({});
      expect(result.success, isFalse);
      expect(result.error, contains('No transactions'));
    });

    test('returns the exact sum the calculator would produce', () async {
      final txns = [
        Transaction(
          userId: 1,
          accountId: 1,
          categoryId: 1,
          type: TransactionType.income,
          amount: 45000,
          date: DateTime(2026, 8, 1),
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 1),
        ),
        Transaction(
          userId: 1,
          accountId: 1,
          categoryId: 2,
          type: TransactionType.expense,
          amount: 20420,
          date: DateTime(2026, 8, 10),
          createdAt: DateTime(2026, 8, 10),
          updatedAt: DateTime(2026, 8, 10),
        ),
      ];
      final registry = FinancialToolsRegistry(
        userId: 1,
        transactionRepository: FakeTransactionRepository(txns),
        accountRepository: FakeAccountRepository(),
        budgetRepository: FakeBudgetRepository(),
        goalRepository: FakeGoalRepository([]),
        recurringRepository: FakeRecurringRepository([]),
      );

      final result = await _find(registry.buildTools(), 'get_current_balance').execute({});
      expect(result.success, isTrue);
      expect(result.data['balance'], 24580);
    });
  });

  group('calculate_affordable_spending', () {
    test('requires proposedAmount/startDate/endDate rather than guessing them', () async {
      final registry = FinancialToolsRegistry(
        userId: 1,
        transactionRepository: FakeTransactionRepository([]),
        accountRepository: FakeAccountRepository(),
        budgetRepository: FakeBudgetRepository(),
        goalRepository: FakeGoalRepository([]),
        recurringRepository: FakeRecurringRepository([]),
      );

      final result = await _find(registry.buildTools(), 'calculate_affordable_spending').execute({});
      expect(result.success, isFalse);
    });
  });

  group('get_budget_status', () {
    test('reports over-budget correctly rather than clamping to 100%', () async {
      final budget = Budget(
        id: 1,
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
      final txns = [
        Transaction(
          userId: 1,
          accountId: 1,
          categoryId: 1,
          type: TransactionType.expense,
          amount: 1500,
          date: DateTime(2026, 8, 10),
          createdAt: DateTime(2026, 8, 10),
          updatedAt: DateTime(2026, 8, 10),
        ),
      ];
      final registry = FinancialToolsRegistry(
        userId: 1,
        transactionRepository: FakeTransactionRepository(txns),
        accountRepository: FakeAccountRepository(),
        budgetRepository: FakeBudgetRepository(active: budget),
        goalRepository: FakeGoalRepository([]),
        recurringRepository: FakeRecurringRepository([]),
      );

      final result = await _find(registry.buildTools(), 'get_budget_status').execute({'month': '2026-08-15'});
      expect(result.data['percentUsed'], greaterThan(1.0));
      expect(result.data['remaining'], -500);
    });
  });
}
