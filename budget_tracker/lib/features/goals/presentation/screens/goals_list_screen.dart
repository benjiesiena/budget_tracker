import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/theme/app_spacing.dart";
import "../../../../shared/presentation/providers/app_providers.dart";
import "../../../../shared/presentation/widgets/empty_state.dart";
import "../../../../shared/presentation/widgets/goal_progress_widget.dart";
import "../providers/goals_provider.dart";
import "add_goal_screen.dart";

/// Goals list (PRD wireframe 9.7). Each card shows progress plus a
/// suggested monthly contribution computed via
/// FinancialCalculator.calculateRequiredMonthlySavings — never a made-up
/// number.
class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final calculator = ref.watch(financialCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Goals"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddGoalScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text("New Goal"),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Couldn't load goals: $e")),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: "No goals yet",
              message: "Set a savings goal — an emergency fund, a trip, anything — and track progress toward it.",
              actionLabel: "New Goal",
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddGoalScreen()),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final goal in goals)
                GoalProgressWidget(
                  goal: goal,
                  suggestedMonthlyContribution:
                      calculator.calculateRequiredMonthlySavings(goal, from: DateTime.now()),
                ),
            ],
          );
        },
      ),
    );
  }
}
