import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/presentation/providers/app_providers.dart';
import '../../../shared/presentation/widgets/financial_summary.dart';
import '../../../shared/presentation/widgets/budget_progress.dart';
import '../../../shared/presentation/widgets/insight_card.dart';
import '../../budgets/presentation/providers/budgets_provider.dart';
import '../../categories/presentation/categories_provider.dart';
import '../../transactions/presentation/providers/transactions_provider.dart';

/// Home screen (PRD 9.3): available balance, income/expense split, budget
/// status, a per-category spending overview, and a single AI insight card.
/// All numbers here are computed from the same [FinancialCalculator] the AI
/// tools use, so this screen and the assistant can never show different
/// figures for the same underlying data.
class HomeScreen extends ConsumerWidget {
  final VoidCallback? onOpenAssistant;
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.onOpenAssistant, this.onOpenSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final budgetAsync = ref.watch(activeBudgetProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final calculator = ref.watch(financialCalculatorProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: onOpenSettings),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Couldn\'t load your data: $e')),
        data: (transactions) {
          final balance = calculator.calculateCurrentBalance(transactions);
          final income = calculator.calculateMonthlyIncome(transactions, now);
          final expenses = calculator.calculateMonthlyExpenses(transactions, now);
          final byCategory = calculator.calculateExpensesByCategory(transactions, now);
          final categories = categoriesAsync.valueOrNull ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transactionsProvider);
              ref.invalidate(activeBudgetProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(DateFormat.yMMMM().format(now), style: AppTypography.sectionHeading),
                const SizedBox(height: AppSpacing.md),
                FinancialSummary(label: 'Available Balance', amount: balance, isPositive: balance >= 0),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: FinancialSummary(label: 'Income', amount: income, isPositive: true)),
                    Expanded(child: FinancialSummary(label: 'Expenses', amount: expenses, isPositive: false)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                budgetAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (budgetState) {
                    if (budgetState.budget == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budget Status', style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
                        const SizedBox(height: AppSpacing.sm),
                        BudgetProgress(
                          label: budgetState.budget!.name,
                          spent: budgetState.spent,
                          budget: budgetState.budget!.totalBudget,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    );
                  },
                ),
                if (byCategory.isNotEmpty) ...[
                  Text('Spending Overview', style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
                  const SizedBox(height: AppSpacing.sm),
                  ..._spendingOverviewRows(context, byCategory, categories, expenses),
                  const SizedBox(height: AppSpacing.lg),
                ],
                InsightCard(
                  title: 'AI Insight',
                  message: byCategory.isEmpty
                      ? 'Add a few transactions and I\'ll start surfacing spending patterns here.'
                      : 'Ask the AI assistant "Where did I spend the most this month?" for a full breakdown.',
                  actionLabel: 'Ask the assistant',
                  onAction: onOpenAssistant,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _spendingOverviewRows(
    BuildContext context,
    Map<int, double> byCategory,
    List categories,
    double totalExpenses,
  ) {
    final palette = context.appColors;
    final entries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).map((e) {
      final category = categories.where((c) => c.id == e.key).firstOrNull;
      final name = category?.name ?? 'Category #${e.key}';
      final fraction = totalExpenses <= 0 ? 0.0 : (e.value / totalExpenses).clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text(name, style: AppTypography.body, overflow: TextOverflow.ellipsis)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: palette.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(palette.primary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 70,
              child: Text(
                CurrencyFormatter.format(e.value),
                textAlign: TextAlign.right,
                style: AppTypography.supporting,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
