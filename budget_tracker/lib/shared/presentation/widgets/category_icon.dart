import "package:flutter/material.dart";
import "../../../core/theme/app_spacing.dart";

/// Small icon chip used everywhere a category is shown (transaction rows,
/// budget lines, category pickers). Spec: 40px, 12px radius, 20% opacity bg.
class CategoryIconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const CategoryIconWidget({super.key, required this.icon, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
