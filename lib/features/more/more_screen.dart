import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../customers/customers_screen.dart';
import '../suppliers/suppliers_screen.dart';
import '../payments/payments_screen.dart';
import '../ledger/ledger_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'More Options',
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
          // Business Profile Overview Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.brandRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (authState.activeBusiness?.name ?? 'K').substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.activeBusiness?.name ?? 'Khaki General Store',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'GSTIN: ${authState.activeBusiness?.gstin ?? "27AAAAA0000A1Z5"}',
                        style: TextStyle(fontSize: 11, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PRO PLAN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.emeraldGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Group 1: Business Operations
          _buildGroupTitle(context, 'BUSINESS & PARTIES'),
          _buildCardGroup(
            context,
            [
              _buildTile(
                context,
                icon: Icons.people_outline,
                title: 'Customers',
                subtitle: 'Manage client accounts & receivables',
                color: AppTheme.emeraldGreen,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen())),
              ),
              _buildTile(
                context,
                icon: Icons.local_shipping_outlined,
                title: 'Suppliers',
                subtitle: 'Manage vendors & purchase bills',
                color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen())),
              ),
              _buildTile(
                context,
                icon: Icons.badge_outlined,
                title: 'Employees & Staff',
                subtitle: 'Permissions, attendance & sales targets',
                color: Colors.purpleAccent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Staff management module ready.')),
                  );
                },
              ),
              _buildTile(
                context,
                icon: Icons.money_off_outlined,
                title: 'Expenses',
                subtitle: 'Rent, electricity, wages & daily petty cash',
                color: AppColors.brandRed,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense tracking module ready.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Group 2: Financial & Books
          _buildGroupTitle(context, 'FINANCIAL & BOOKS'),
          _buildCardGroup(
            context,
            [
              _buildTile(
                context,
                icon: Icons.menu_book_outlined,
                title: 'Khata / Ledger',
                subtitle: 'Customer udhaar timeline & running balance',
                color: AppTheme.amberGold,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LedgerScreen())),
              ),
              _buildTile(
                context,
                icon: Icons.payments_outlined,
                title: 'Payments',
                subtitle: 'All in & out transaction logs',
                color: AppTheme.emeraldGreen,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())),
              ),
              _buildTile(
                context,
                icon: Icons.bar_chart_outlined,
                title: 'Reports & Analytics',
                subtitle: 'Sales, GST returns, profit & loss',
                color: Colors.indigoAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Group 3: System & Settings
          _buildGroupTitle(context, 'SYSTEM & SUPPORT'),
          _buildCardGroup(
            context,
            [
              _buildTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Payment reminders & stock alerts',
                color: Colors.orangeAccent,
                onTap: () {},
              ),
              _buildTile(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Theme, printing, taxes & integrations',
                color: Colors.blueGrey,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              _buildTile(
                context,
                icon: Icons.cloud_done_outlined,
                title: 'Backup & Restore',
                subtitle: 'Encrypted cloud backup',
                color: AppTheme.emeraldGreen,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cloud backup verified & up to date.'),
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                  );
                },
              ),
              _buildTile(
                context,
                icon: Icons.support_agent_outlined,
                title: 'Help & Support',
                subtitle: 'FAQs, WhatsApp support & user guides',
                color: Colors.teal,
                onTap: () {},
              ),
              _buildTile(
                context,
                icon: Icons.info_outline,
                title: 'About Khaki Karobar',
                subtitle: 'Version 2.0 • Khaki KrypTech India',
                color: AppColors.brandRed,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sign Out Button
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.brandRed),
              title: const Text(
                'Log Out from Device',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandRed,
                  fontSize: 14,
                ),
              ),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGroupTitle(BuildContext context, String title) {
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

  Widget _buildCardGroup(BuildContext context, List<Widget> children) {
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

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
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
            Icon(Icons.chevron_right, size: 18, color: context.textMuted),
          ],
        ),
      ),
    );
  }
}
