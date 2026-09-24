import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_selector_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.activeBusiness?.name ?? 'Khaki General Store',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimary),
                ),
                const Text(
                  'Khaki Karobari Live',
                  style: TextStyle(fontSize: 10, color: AppTheme.emeraldGreen),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Change Theme (Light / Dark / System)',
            icon: Icon(
              context.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: context.isDarkMode ? Colors.indigo.shade200 : Colors.amber.shade700,
            ),
            onPressed: () => showThemeSelectorDialog(context, ref),
          ),
          IconButton(
            tooltip: 'Refresh Metrics',
            icon: Icon(Icons.refresh, color: context.textPrimary),
            onPressed: () => ref.refresh(dashboardMetricsProvider),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: Icon(Icons.logout, color: context.textPrimary),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardMetricsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning, ${authState.user?.name ?? 'Owner'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Here is your business snapshot today',
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, color: AppTheme.emeraldGreen, size: 8),
                        SizedBox(width: 4),
                        Text('Synced', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Metrics Cards
              metricsAsync.when(
                data: (metrics) => Column(
                  children: [
                    // Row 1: Today's Sales & Purchases
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: "Today's Sales",
                            value: '₹${metrics.todaySales.toStringAsFixed(0)}',
                            icon: Icons.trending_up,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: "Today's Purchase",
                            value: '₹${metrics.todayPurchase.toStringAsFixed(0)}',
                            icon: Icons.shopping_bag_outlined,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Receivables & Payables
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Receivables (Due)',
                            value: '₹${metrics.totalReceivables.toStringAsFixed(0)}',
                            icon: Icons.call_received,
                            color: AppTheme.amberGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Payables (Owed)',
                            value: '₹${metrics.totalPayables.toStringAsFixed(0)}',
                            icon: Icons.call_made,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Cash Balance
                    _buildMetricCard(
                      context: context,
                      title: 'Cash Balance in Drawer',
                      value: '₹${metrics.cashBalance.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppTheme.primaryRed,
                      fullWidth: true,
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppTheme.primaryRed),
                  ),
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade400.withValues(alpha: 0.3)),
                  ),
                  child: Text('Error loading live metrics: $e', style: const TextStyle(color: AppColors.error)),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  _buildQuickAction(
                    context: context,
                    icon: Icons.point_of_sale,
                    label: '+ New Sale',
                    onTap: () => context.push('/sales/new'),
                  ),
                  _buildQuickAction(
                    context: context,
                    icon: Icons.person_add_alt_1,
                    label: '+ Add Customer',
                    onTap: () => context.push('/customers'),
                  ),
                  _buildQuickAction(
                    context: context,
                    icon: Icons.add_box_outlined,
                    label: '+ Add Product',
                    onTap: () => context.push('/products'),
                  ),
                  _buildQuickAction(
                    context: context,
                    icon: Icons.receipt_long,
                    label: 'Sales Invoices',
                    onTap: () => context.push('/sales'),
                  ),
                  _buildQuickAction(
                    context: context,
                    icon: Icons.payments_outlined,
                    label: '+ Add Payment',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment registered and synchronized.')),
                    ),
                  ),
                  _buildQuickAction(
                    context: context,
                    icon: Icons.palette_outlined,
                    label: 'Theme Settings',
                    onTap: () => showThemeSelectorDialog(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.borderColor, width: 0.8)),
        ),
        child: BottomNavigationBar(
          backgroundColor: context.surfaceColor,
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: context.textMuted,
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            if (index == 1) context.push('/sales');
            if (index == 2) context.push('/products');
            if (index == 3) context.push('/customers');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_outlined), label: 'Sales'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: context.textSecondary),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
          boxShadow: context.isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryRed, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
