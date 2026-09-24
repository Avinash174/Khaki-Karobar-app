import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import 'app_colors.dart';

/// Interactive modal dialog allowing users to switch between Light, Dark, and System theme modes
void showThemeSelectorDialog(BuildContext context, WidgetRef ref) {
  final currentMode = ref.read(themeProvider);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      final theme = Theme.of(dialogContext);
      final isDark = theme.brightness == Brightness.dark;

      return AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_outlined, color: AppColors.brandRed, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Select Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context: dialogContext,
              ref: ref,
              title: 'Light',
              subtitle: 'Clean, minimal, high readability',
              icon: Icons.wb_sunny_rounded,
              iconColor: Colors.amber.shade600,
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context: dialogContext,
              ref: ref,
              title: 'Dark',
              subtitle: 'Sleek, true dark UI hierarchy',
              icon: Icons.nightlight_round,
              iconColor: Colors.indigo.shade300,
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context: dialogContext,
              ref: ref,
              title: 'System Default',
              subtitle: 'Follows operating system appearance',
              icon: Icons.settings_brightness_rounded,
              iconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget _buildThemeOption({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String subtitle,
  required IconData icon,
  required Color iconColor,
  required ThemeMode mode,
  required bool isSelected,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return InkWell(
    onTap: () {
      ref.read(themeProvider.notifier).setThemeMode(mode);
      Navigator.of(context).pop();
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.brandRed.withValues(alpha: isDark ? 0.2 : 0.08)
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.brandRed
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.brandRed : iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.brandRed : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.brandRed, size: 20),
        ],
      ),
    ),
  );
}
