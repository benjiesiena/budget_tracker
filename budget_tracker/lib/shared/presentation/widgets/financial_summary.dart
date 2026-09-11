import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/utils/currency_formatter.dart";

class FinancialSummary extends StatelessWidget {
  final String label;
  final double amount;
  final String? subtitle;
  final bool? isPositive;

  const FinancialSummary({super.key, required this.label, required this.amount, this.subtitle, this.isPositive});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final color = isPositive == null ? palette.textPrimary : (isPositive! ? palette.positive : palette.negative);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.supporting.copyWith(color: palette.textSecondary)),
        const SizedBox(height: 4),
        Text(CurrencyFormatter.format(amount), style: AppTypography.primaryValue.copyWith(color: color, fontSize: 22)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: AppTypography.caption.copyWith(color: palette.textTertiary)),
        ],
      ],
    );
  }
}
