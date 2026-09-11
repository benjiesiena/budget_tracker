import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Builds the light and dark [ThemeData] used across the app.
///
/// Both themes are built from the same function so they can never drift out
/// of sync structurally — only the [AppColorPalette] passed in differs.
/// Text styles are explicitly colored here (not left to default to black),
/// which is what makes a plain `Text('...', style: AppTypography.body)`
/// elsewhere in the app automatically render correctly in dark mode without
/// every call site needing to pass a color.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColorPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      fontFamily: AppTypography.fontFamily,
      colorScheme: isDark
          ? ColorScheme.dark(primary: palette.primary, surface: palette.surface, error: palette.negative)
          : ColorScheme.light(primary: palette.primary, surface: palette.surface, error: palette.negative),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: palette.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),
      textTheme: TextTheme(
        headlineMedium: AppTypography.pageTitle.copyWith(color: palette.textPrimary),
        titleLarge: AppTypography.sectionHeading.copyWith(color: palette.textPrimary),
        displaySmall: AppTypography.primaryValue.copyWith(color: palette.textPrimary),
        bodyMedium: AppTypography.body.copyWith(color: palette.textPrimary),
        bodySmall: AppTypography.supporting.copyWith(color: palette.textSecondary),
        labelSmall: AppTypography.caption.copyWith(color: palette.textTertiary),
        labelLarge: AppTypography.button.copyWith(color: palette.textPrimary),
      ),
      iconTheme: IconThemeData(color: palette.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceVariant,
        hintStyle: AppTypography.body.copyWith(color: palette.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    );
  }
}
