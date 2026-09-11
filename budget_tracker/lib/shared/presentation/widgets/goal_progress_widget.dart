import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/utils/currency_formatter.dart";
import "../../domain/entities/financial_goal.dart";

class GoalProgressWidget extends StatelessWidget {
  final FinancialGoal goal;
  final double? suggestedMonthlyContribution;

  const GoalProgressWidget({super.key, required this.goal, this.suggestedMonthlyContribution});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final pct = (goal.progressPercentage * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.name, style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: goal.progressPercentage,
              minHeight: 8,
              backgroundColor: palette.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(palette.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "${CurrencyFormatter.format(goal.currentAmount)} of ${CurrencyFormatter.format(goal.targetAmount)} ($pct%)",
            style: AppTypography.supporting.copyWith(color: palette.textSecondary),
          ),
          Text(
            "${CurrencyFormatter.format(goal.remainingAmount)} remaining",
            style: AppTypography.caption.copyWith(color: palette.textTertiary),
          ),
          if (goal.targetDate != null)
            Text(
              "Target: ${DateFormat.yMMM().format(goal.targetDate!)}",
              style: AppTypography.caption.copyWith(color: palette.textTertiary),
            ),
          if (suggestedMonthlyContribution != null && suggestedMonthlyContribution! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                "Save ${CurrencyFormatter.format(suggestedMonthlyContribution!)}/month to reach goal",
                style: AppTypography.caption.copyWith(color: palette.primary),
              ),
            ),
        ],
      ),
    );
  }
}
