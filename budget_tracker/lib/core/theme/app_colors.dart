import 'package:flutter/material.dart';

/// One full set of semantic colors — either the light or the dark palette.
/// Previously `AppColors` and `AppColorsDark` were two separate classes of
/// unrelated static constants, and widgets across the app hardcoded
/// `AppColors.textPrimary` etc. directly. That's what caused dark-mode text
/// to render in *light-mode* colors regardless of the device's actual
/// theme — the widget had no way to know which palette it should be using.
/// Now there's one shape ([AppColorPalette]) with a light and a dark
/// instance, and widgets ask for the right one via [AppColorsContext] below.
class AppColorPalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color positive;
  final Color positiveLight;
  final Color negative;
  final Color negativeLight;
  final Color warning;
  final Color warningLight;
  final Color border;
  final Color divider;
  final Color interactive;
  final Color interactiveHover;
  final Color interactivePressed;

  const AppColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.positive,
    required this.positiveLight,
    required this.negative,
    required this.negativeLight,
    required this.warning,
    required this.warningLight,
    required this.border,
    required this.divider,
    required this.interactive,
    required this.interactiveHover,
    required this.interactivePressed,
  });
}

class AppColors {
  AppColors._();

  /// Light-mode palette. See design spec section 8.1.
  static const light = AppColorPalette(
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF666666),
    textTertiary: Color(0xFF999999),
    textDisabled: Color(0xFFCCCCCC),
    primary: Color(0xFF0066CC),
    primaryLight: Color(0xFF3399FF),
    primaryDark: Color(0xFF004C99),
    positive: Color(0xFF10B981),
    positiveLight: Color(0xFFD1FAE5),
    negative: Color(0xFFEF4444),
    negativeLight: Color(0xFFFEE2E2),
    warning: Color(0xFFF59E0B),
    warningLight: Color(0xFFFEF3C7),
    border: Color(0xFFE5E5E5),
    divider: Color(0xFFEEEEEE),
    interactive: Color(0xFF0066CC),
    interactiveHover: Color(0xFF3399FF),
    interactivePressed: Color(0xFF004C99),
  );

  /// Dark-mode palette. See design spec section 8.1.
  static const dark = AppColorPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2C2C2C),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB3B3B3),
    textTertiary: Color(0xFF808080),
    textDisabled: Color(0xFF4D4D4D),
    primary: Color(0xFF4D9FFF),
    primaryLight: Color(0xFF80BFFF),
    primaryDark: Color(0xFF3380CC),
    positive: Color(0xFF34D399),
    positiveLight: Color(0xFF064E3B),
    negative: Color(0xFFF87171),
    negativeLight: Color(0xFF7F1D1D),
    warning: Color(0xFFFBBF24),
    warningLight: Color(0xFF78350F),
    border: Color(0xFF333333),
    divider: Color(0xFF2A2A2A),
    interactive: Color(0xFF4D9FFF),
    interactiveHover: Color(0xFF80BFFF),
    interactivePressed: Color(0xFF3380CC),
  );
}

/// Resolves the correct palette for the *current* theme brightness.
///
/// Any widget that needs a semantic color not already covered by
/// `Theme.of(context).textTheme` (see AppTheme, which now colors the text
/// theme per-brightness) should read it through `context.appColors`, never
/// through `AppColors.light`/`AppColors.dark` directly.
extension AppColorsContext on BuildContext {
  AppColorPalette get appColors =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}
