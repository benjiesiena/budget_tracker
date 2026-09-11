import "../entities/financial_goal.dart";

abstract class GoalRepository {
  Future<FinancialGoal> create(FinancialGoal goal);
  Future<FinancialGoal> update(FinancialGoal goal);
  Future<void> delete(int id);
  Future<FinancialGoal?> getById(int id);
  Future<List<FinancialGoal>> getAllForUser(int userId, {bool activeOnly = true});
}
