import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_spacing.dart";

/// Large numeric-entry field used for amounts (onboarding income/budget
/// screens, add-transaction screen). Renders the currency symbol as a
/// fixed prefix and keeps everything else at primary-value type scale.
class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const AmountInput({
    super.key,
    required this.controller,
    this.currencySymbol = "\u20b1",
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(currencySymbol, style: AppTypography.primaryValue.copyWith(color: palette.textSecondary)),
            const SizedBox(width: AppSpacing.xs),
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: AppTypography.primaryValue.copyWith(color: palette.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  hintText: "0",
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(errorText!, style: AppTypography.caption.copyWith(color: palette.negative)),
        ],
      ],
    );
  }
}
