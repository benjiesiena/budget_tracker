import "../entities/budget.dart";

abstract class BudgetRepository {
  Future<Budget> create(Budget budget, List<BudgetItem> items);
  Future<Budget> update(Budget budget);
  Future<void> delete(int id);
  Future<Budget?> getActiveForDate(int userId, DateTime date);
  Future<List<Budget>> getAllForUser(int userId);
  Future<List<BudgetItem>> getItemsForBudget(int budgetId);
  Future<BudgetItem> upsertItem(BudgetItem item);
}
