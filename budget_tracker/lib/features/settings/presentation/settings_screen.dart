import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_spacing.dart";

/// Settings screen (PRD wireframe 9.10). Wired as static UI here — each
/// row would read/write `app_settings` via a SettingsRepository (same
/// pattern as every other repository in shared/data/repositories) and the
/// security rows would call SecurityManager directly.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _section(context, "Preferences", [
            _row(context, "Currency", trailing: "PHP"),
            _row(context, "Theme", trailing: "System"),
            _row(context, "Language", trailing: "English"),
          ]),
          _section(context, "Security", [
            _row(context, "App Lock", trailing: "On"),
            _row(context, "Biometrics", trailing: "On"),
            _row(context, "Auto-lock timeout", trailing: "5 min"),
            _row(context, "Change PIN"),
          ]),
          _section(context, "AI Settings", [
            _row(context, "AI Memory", trailing: "On"),
            _row(context, "Model Version", trailing: "v1.0 (rule-based)"),
            _row(context, "Clear AI Memory"),
          ]),
          _section(context, "Notifications", [
            _row(context, "Budget Alerts", trailing: "On"),
            _row(context, "Goal Reminders", trailing: "On"),
            _row(context, "Upcoming Expenses", trailing: "On"),
          ]),
          _section(context, "Data", [
            _row(context, "Backup & Restore"),
            _row(context, "Export Data"),
            _row(context, "Import Data"),
            _row(context, "Clear All Data", isDestructive: true),
          ]),
          _section(context, "About", [
            _row(context, "Version", trailing: "1.0.0"),
            _row(context, "Privacy Policy"),
            _row(context, "Terms of Service"),
            _row(context, "Send Feedback"),
          ]),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
          child: Text(title, style: AppTypography.supporting.copyWith(color: context.appColors.textSecondary)),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _row(BuildContext context, String label, {String? trailing, bool isDestructive = false}) {
    final palette = context.appColors;
    return ListTile(
      title: Text(label, style: AppTypography.body.copyWith(color: isDestructive ? palette.negative : null)),
      trailing: trailing != null
          ? Text(trailing, style: AppTypography.supporting.copyWith(color: palette.textSecondary))
          : Icon(Icons.chevron_right, color: palette.textTertiary),
      onTap: () {},
    );
  }
}
