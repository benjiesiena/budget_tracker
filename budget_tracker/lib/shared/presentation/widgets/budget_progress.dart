import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/utils/currency_formatter.dart";

/// Linear budget bar with color coding per PRD 8.6:
/// green (<80%), orange (80-100%), red (>100%).
class BudgetProgress extends StatelessWidget {
  final String label;
  final double spent;
  final double budget;

  const BudgetProgress({super.key, required this.label, required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final pct = budget <= 0 ? 0.0 : (spent / budget);
    final color = pct >= 1.0 ? palette.negative : (pct >= 0.8 ? palette.warning : palette.positive);
    final remaining = budget - spent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body),
            Text(
              "${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget)}",
              style: AppTypography.supporting.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: palette.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          remaining >= 0
              ? "${CurrencyFormatter.format(remaining)} remaining"
              : "${CurrencyFormatter.format(remaining.abs())} over budget",
          style: AppTypography.caption.copyWith(color: remaining >= 0 ? palette.textTertiary : palette.negative),
        ),
      ],
    );
  }
}
