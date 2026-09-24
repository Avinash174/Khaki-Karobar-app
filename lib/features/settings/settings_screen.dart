import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_selector_dialog.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Account
          _buildSectionHeader(context, 'ACCOUNT'),
          _buildSettingsGroup(
            context,
            [
              _buildSettingTile(
                context,
                icon: Icons.person_outline,
                title: 'User Profile',
                subtitle: authState.user?.name ?? 'Business Owner',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.security_outlined,
                title: 'Security & App PIN',
                subtitle: 'Two-factor auth and screen lock',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Business
          _buildSectionHeader(context, 'BUSINESS'),
          _buildSettingsGroup(
            context,
            [
              _buildSettingTile(
                context,
                icon: Icons.storefront_outlined,
                title: 'Business Profile',
                subtitle: authState.activeBusiness?.name ?? 'Khaki General Store',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Invoice & Bill Settings',
                subtitle: 'Prefix, terms & conditions, signature',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.percent_outlined,
                title: 'GST & Tax Settings',
                subtitle: authState.activeBusiness?.gstin ?? '27AAAAA0000A1Z5',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.qr_code_outlined,
                title: 'Payment & UPI Settings',
                subtitle: 'Configure UPI ID & QR on invoices',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Application
          _buildSectionHeader(context, 'APPLICATION'),
          _buildSettingsGroup(
            context,
            [
              _buildSettingTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Appearance / Theme',
                subtitle: context.isDarkMode ? 'Dark Theme' : 'Light Theme',
                trailing: Text(
                  context.isDarkMode ? 'Dark' : 'Light',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandRed, fontSize: 12),
                ),
                onTap: () => showThemeSelectorDialog(context, ref),
              ),
              _buildSettingTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Payment reminders & low-stock alerts',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English (US / India)',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.currency_rupee,
                title: 'Currency Symbol',
                subtitle: '₹ INR (Indian Rupee)',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Integrations
          _buildSectionHeader(context, 'INTEGRATIONS'),
          _buildSettingsGroup(
            context,
            [
              _buildSettingTile(
                context,
                icon: Icons.chat_outlined,
                title: 'WhatsApp Business API',
                subtitle: 'Automated billing dispatch',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.mail_outline,
                title: 'Email Delivery (SMTP)',
                subtitle: 'Send invoices directly to clients',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.account_balance_outlined,
                title: 'Payment Gateway',
                subtitle: 'Razorpay / Cashfree UPI integrated',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Data & Backup
          _buildSectionHeader(context, 'DATA & BACKUP'),
          _buildSettingsGroup(
            context,
            [
              _buildSettingTile(
                context,
                icon: Icons.cloud_upload_outlined,
                title: 'Cloud Backup & Sync',
                subtitle: 'Auto-sync with encrypted cloud',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data synced with cloud storage.'),
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                  );
                },
              ),
              _buildSettingTile(
                context,
                icon: Icons.file_download_outlined,
                title: 'Export / Backup Excel',
                subtitle: 'Download complete ledger & products',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Support
          _buildSectionHeader(context, 'SUPPORT'),
          _buildSettingsGroup(
            context,
            [
              _buildSettingTile(
                context,
                icon: Icons.help_outline,
                title: 'Help Center & Tutorials',
                subtitle: 'Guides on invoicing and GST filing',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.headset_mic_outlined,
                title: 'Contact Khaki Support',
                subtitle: 'Priority 24/7 business assistance',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, size: 18, color: context.textMuted),
          ],
        ),
      ),
    );
  }
}
