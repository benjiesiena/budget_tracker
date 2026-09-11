import "package:flutter/material.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../domain/ai_message.dart";

/// Chat bubble per PRD 8.6 AIMessage spec: user right-aligned/primary bg,
/// assistant left-aligned/surface-variant bg, 16px radius, 80% max width.
class AIMessageBubble extends StatelessWidget {
  final AIMessage message;

  const AIMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isUser = message.role == AIMessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.all(AppSpacing.sm + 4),
          decoration: BoxDecoration(
            color: isUser ? palette.primary : palette.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Text(
            message.content,
            style: AppTypography.body.copyWith(color: isUser ? Colors.white : palette.textPrimary),
          ),
        ),
      ),
    );
  }
}
