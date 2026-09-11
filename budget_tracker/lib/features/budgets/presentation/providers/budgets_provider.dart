import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../../shared/domain/entities/budget.dart";
import "../../../../shared/presentation/providers/app_providers.dart";

class ActiveBudgetState {
  final Budget? budget;
  final List<BudgetItem> items;
  final double spent;
  final double remaining;
  final double percentUsed;

  const ActiveBudgetState({
    this.budget,
    this.items = const [],
    this.spent = 0,
    this.remaining = 0,
    this.percentUsed = 0,
  });
}

/// Resolves the budget active for *today* plus its live usage, recomputed
/// from the FinancialCalculator against current transactions. This mirrors
/// exactly what the `get_budget_status` AI tool returns, so the Budget
/// screen and the AI assistant can never disagree about the numbers.
final activeBudgetProvider = FutureProvider<ActiveBudgetState>((ref) async {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final txnRepo = ref.watch(transactionRepositoryProvider);
  final calculator = ref.watch(financialCalculatorProvider);
  final userId = ref.watch(currentUserIdProvider);

  final budget = await budgetRepo.getActiveForDate(userId, DateTime.now());
  if (budget == null) return const ActiveBudgetState();

  final items = await budgetRepo.getItemsForBudget(budget.id!);
  final txns = await txnRepo.getAllForUser(userId);

  return ActiveBudgetState(
    budget: budget,
    items: items,
    spent: calculator.calculateBudgetUsage(budget, txns),
    remaining: calculator.calculateBudgetRemaining(budget, txns),
    percentUsed: calculator.calculateBudgetPercentage(budget, txns),
  );
});
