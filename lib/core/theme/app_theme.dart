import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

export 'app_colors.dart';
export 'light_theme.dart';
export 'dark_theme.dart';

/// Central AppTheme class containing both Light and Dark themes
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => lightThemeData;
  static ThemeData get darkTheme => darkThemeData;
  static ThemeData get light => lightThemeData;
  static ThemeData get dark => darkThemeData;

  // Semantic & Brand Tokens
  static const Color primaryRed = AppColors.brandRed;
  static const Color darkBackground = AppColors.darkBackground;
  static const Color cardSurface = AppColors.darkSurface;
  static const Color borderSubtle = AppColors.darkBorder;
  static const Color textMuted = AppColors.darkTextMuted;
  static const Color emeraldGreen = AppColors.success;
  static const Color amberGold = AppColors.warning;
}

// Named aliases for ThemeData getters
ThemeData get lightThemeData => lightTheme;
ThemeData get darkThemeData => darkTheme;

/// BuildContext extension for dynamic, contrast-safe theme resolution
extension ThemeHelper on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).cardTheme.color ?? Theme.of(this).colorScheme.surface;
  Color get borderColor => Theme.of(this).colorScheme.outline;
  Color get textPrimary => Theme.of(this).colorScheme.onSurface;
  Color get textSecondary => isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get textMuted => isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get inputFill => isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill;
}
