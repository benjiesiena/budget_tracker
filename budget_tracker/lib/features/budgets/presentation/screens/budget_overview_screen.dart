import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/presentation/widgets/budget_progress.dart";
import "../../../../shared/presentation/widgets/empty_state.dart";
import "../../../categories/presentation/categories_provider.dart";
import "../../../transactions/presentation/providers/transactions_provider.dart";
import "../../../../shared/presentation/providers/app_providers.dart";
import "../providers/budgets_provider.dart";

import "add_budget_screen.dart";

/// Budget overview (PRD wireframe 9.6): total budget summary plus a
/// per-category breakdown, each bar color-coded by BudgetProgress.
class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(activeBudgetProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final calculator = ref.watch(financialCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text("New Budget"),
          ),
        ],
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Couldn't load budget: $e")),
        data: (state) {
          if (state.budget == null) {
            return EmptyState(
              icon: Icons.pie_chart_outline,
              title: "No active budget",
              message: "Create a monthly budget to track spending against a target.",
              actionLabel: "Create Budget",
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
              ),
            );
          }

          final categories = categoriesAsync.valueOrNull ?? [];
          final transactions = transactionsAsync.valueOrNull ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(state.budget!.name, style: AppTypography.pageTitle.copyWith(fontSize: 20)),
              const SizedBox(height: AppSpacing.md),
              BudgetProgress(label: "Total", spent: state.spent, budget: state.budget!.totalBudget),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Text("Category Budgets", style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              for (final item in state.items) ...[
                Builder(builder: (context) {
                  final category = categories.where((c) => c.id == item.categoryId).firstOrNull;
                  final used = calculator.calculateBudgetItemUsage(item.categoryId, state.budget!, transactions);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: BudgetProgress(label: category?.name ?? "Category #${item.categoryId}", spent: used, budget: item.amount),
                  );
                }),
              ],
              if (state.items.isEmpty)
                Text(
                  "This budget has no category limits set yet.",
                  style: AppTypography.body.copyWith(color: context.appColors.textSecondary),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
