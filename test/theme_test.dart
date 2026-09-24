import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/core/theme/app_theme.dart';
import 'package:khaki_karobari/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Khaki Karobari Theme System Tests', () {
    test('Light Theme has correct brand colors and brightness', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.primaryColor, AppColors.brandRed);
      expect(theme.colorScheme.primary, AppColors.brandRed);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
    });

    test('Dark Theme has correct brand colors and brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.primaryColor, AppColors.brandRed);
      expect(theme.colorScheme.primary, AppColors.brandRed);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
    });

    test('ThemeNotifier changes modes and persists appropriately', () async {
      final notifier = ThemeNotifier();
      // Wait for any async initial load to settle
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state, ThemeMode.system);

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, ThemeMode.system);
    });
  });
}
