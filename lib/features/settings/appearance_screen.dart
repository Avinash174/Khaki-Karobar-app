import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'THEME PREFERENCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Text(
              'Choose how Khaki Karobar looks on your device. Changes apply instantly across all screens.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Light Option
            _buildThemeOptionCard(
              context: context,
              title: 'Light Theme',
              subtitle: 'Clean white background with vibrant red accents and crisp dark typography.',
              mode: ThemeMode.light,
              currentMode: currentTheme,
              icon: Icons.wb_sunny_rounded,
              iconColor: Colors.amber.shade700,
              previewColors: const [Colors.white, Color(0xFFF1F5F9), AppColors.brandRed],
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
              },
            ),
            const SizedBox(height: 14),

            // Dark Option
            _buildThemeOptionCard(
              context: context,
              title: 'Dark Theme',
              subtitle: 'Deep charcoal background with high contrast for comfortable low-light use.',
              mode: ThemeMode.dark,
              currentMode: currentTheme,
              icon: Icons.nightlight_round,
              iconColor: Colors.indigo.shade300,
              previewColors: const [Color(0xFF0F172A), Color(0xFF1E293B), AppColors.brandRed],
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
              },
            ),
            const SizedBox(height: 14),

            // System Default Option
            _buildThemeOptionCard(
              context: context,
              title: 'System Default',
              subtitle: 'Automatically sync with your operating system’s light or dark mode setting.',
              mode: ThemeMode.system,
              currentMode: currentTheme,
              icon: Icons.brightness_auto_rounded,
              iconColor: AppColors.brandRed,
              previewColors: const [Colors.white, Color(0xFF0F172A), AppColors.brandRed],
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
              },
            ),
            const SizedBox(height: 28),

            // Information Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.brandRed,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consistent Enterprise Design',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your appearance preference is stored securely on this device and persists across application restarts.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required Color iconColor,
    required List<Color> previewColors,
    required VoidCallback onTap,
  }) {
    final isSelected = currentMode == mode;
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.brandRed
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandRed.withValues(alpha: isDark ? 0.3 : 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Pill
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandRed.withValues(alpha: 0.12)
                    : (isDark ? AppColors.darkInputFill : AppColors.lightInputFill),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.brandRed : iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      // Preview Color Chips
                      Row(
                        children: previewColors
                            .map(
                              (c) => Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandRed
                      : (isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong),
                  width: 2,
                ),
                color: isSelected ? AppColors.brandRed : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
