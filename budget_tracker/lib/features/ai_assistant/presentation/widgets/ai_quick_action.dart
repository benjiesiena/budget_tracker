import "package:flutter/material.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/theme/app_spacing.dart";

/// Pill-shaped quick-prompt chip (PRD 8.6): 36px tall, 18px radius,
/// surface-variant background.
class AIQuickAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AIQuickAction({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.supporting),
        ),
      ),
    );
  }
}
