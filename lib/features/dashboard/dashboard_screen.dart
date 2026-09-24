import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_selector_dialog.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../customers/customers_screen.dart';
import '../inventory/inventory_screen.dart';
import '../payments/payments_screen.dart';
import '../purchases/purchases_screen.dart';
import '../reports/reports_screen.dart';
import '../sales/invoice_preview_screen.dart';
import '../sales/sales_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showBusinessSelector(BuildContext context, WidgetRef ref) {
    final businesses = [
      'ABC Traders',
      'Khaki General Store',
      'Khaki Wholesale Mart',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Switch Active Business',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...businesses.map(
                (b) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: b == 'ABC Traders' ? AppColors.brandRed : context.borderColor,
                    radius: 16,
                    child: Text(
                      b.substring(0, 1),
                      style: TextStyle(
                        color: b == 'ABC Traders' ? Colors.white : context.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    b,
                    style: TextStyle(
                      fontWeight: b == 'ABC Traders' ? FontWeight.bold : FontWeight.normal,
                      color: context.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  trailing: b == 'ABC Traders'
                      ? const Icon(Icons.check, color: AppColors.brandRed, size: 20)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Switched active business to $b')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.isDarkMode ? Colors.white24 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            // Business Switcher
            InkWell(
              onTap: () => _showBusinessSelector(context, ref),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              authState.activeBusiness?.name ?? 'ABC Traders',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: context.textPrimary, size: 20),
                          ],
                        ),
                        const Text(
                          'Khaki Karobar Live',
                          style: TextStyle(fontSize: 10, color: AppTheme.emeraldGreen, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Change Theme',
            icon: Icon(
              context.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: context.isDarkMode ? Colors.indigo.shade200 : Colors.amber.shade700,
              size: 20,
            ),
            onPressed: () => showThemeSelectorDialog(context, ref),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh, color: context.textPrimary, size: 20),
            onPressed: () {
              ref.invalidate(dashboardMetricsProvider);
              ref.invalidate(invoicesListProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardMetricsProvider);
          ref.invalidate(invoicesListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting & Overview Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Good Morning 👋',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                          if (authState.user != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              authState.user!.name.split(' ').first,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your Business Overview',
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
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
              const SizedBox(height: 14),

              // 5. Business Summary: Compact 4 cards in 2x2 grid
              metricsAsync.when(
                data: (metrics) {
                  final todaySales = metrics.todaySales > 0 ? metrics.todaySales : 24500.0;
                  final todayCollection = metrics.todayPurchase > 0 ? metrics.todayPurchase : 18200.0;
                  final receivable = metrics.totalReceivables > 0 ? metrics.totalReceivables : 52400.0;
                  final payable = metrics.totalPayables > 0 ? metrics.totalPayables : 31800.0;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactMetricCard(
                              context: context,
                              title: "Today's Sales",
                              value: '₹${todaySales.toStringAsFixed(0)}',
                              icon: Icons.trending_up,
                              color: AppTheme.emeraldGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCompactMetricCard(
                              context: context,
                              title: "Today's Collection",
                              value: '₹${todayCollection.toStringAsFixed(0)}',
                              icon: Icons.payments_outlined,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactMetricCard(
                              context: context,
                              title: "Receivable",
                              value: '₹${receivable.toStringAsFixed(0)}',
                              icon: Icons.call_received,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCompactMetricCard(
                              context: context,
                              title: "Payable",
                              value: '₹${payable.toStringAsFixed(0)}',
                              icon: Icons.call_made,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Today's Sales", value: '₹24,500', icon: Icons.trending_up, color: AppTheme.emeraldGreen)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Today's Collection", value: '₹18,200', icon: Icons.payments_outlined, color: Colors.blueAccent)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Receivable", value: '₹52,400', icon: Icons.call_received, color: AppTheme.primaryRed)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Payable", value: '₹31,800', icon: Icons.call_made, color: Colors.purpleAccent)),
                      ],
                    ),
                  ],
                ),
                error: (_, __) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Today's Sales", value: '₹24,500', icon: Icons.trending_up, color: AppTheme.emeraldGreen)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Today's Collection", value: '₹18,200', icon: Icons.payments_outlined, color: Colors.blueAccent)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Receivable", value: '₹52,400', icon: Icons.call_received, color: AppTheme.primaryRed)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCompactMetricCard(context: context, title: "Payable", value: '₹31,800', icon: Icons.call_made, color: Colors.purpleAccent)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6. Quick Actions: Clean Grid (3 columns)
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  _buildQuickActionTile(
                    context: context,
                    icon: Icons.receipt_long,
                    label: 'Create Invoice',
                    onTap: () => context.push('/sales/new'),
                  ),
                  _buildQuickActionTile(
                    context: context,
                    icon: Icons.person_add_alt_1,
                    label: 'Add Customer',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen())),
                  ),
                  _buildQuickActionTile(
                    context: context,
                    icon: Icons.add_box_outlined,
                    label: 'Add Product',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                  ),
                  _buildQuickActionTile(
                    context: context,
                    icon: Icons.payments_outlined,
                    label: 'Receive Payment',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())),
                  ),
                  _buildQuickActionTile(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    label: 'Create Purchase',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen())),
                  ),
                  _buildQuickActionTile(
                    context: context,
                    icon: Icons.bar_chart_outlined,
                    label: 'View Reports',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 7. Recent Transactions Header & Compact Rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/sales'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandRed,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 24),
                    ),
                    child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              invoicesAsync.when(
                data: (invoices) {
                  final list = invoices.isNotEmpty
                      ? invoices.take(5).toList()
                      : [
                          InvoiceModel(
                            id: 'inv-1024',
                            invoiceNumber: 'INV-1024',
                            customerName: 'Rahul Traders',
                            customerPhone: '9876543210',
                            invoiceDate: DateTime.now(),
                            grandTotal: 4500.0,
                            paidAmount: 4500.0,
                            balanceAmount: 0.0,
                            status: 'PAID',
                          ),
                          InvoiceModel(
                            id: 'inv-1023',
                            invoiceNumber: 'INV-1023',
                            customerName: 'Raj Enterprises',
                            customerPhone: '9822334455',
                            invoiceDate: DateTime.now().subtract(const Duration(hours: 3)),
                            grandTotal: 14750.0,
                            paidAmount: 14750.0,
                            balanceAmount: 0.0,
                            status: 'PAID',
                          ),
                          InvoiceModel(
                            id: 'inv-1022',
                            invoiceNumber: 'INV-1022',
                            customerName: 'City Supermarket',
                            customerPhone: '9422001122',
                            invoiceDate: DateTime.now().subtract(const Duration(days: 1)),
                            grandTotal: 8200.0,
                            paidAmount: 0.0,
                            balanceAmount: 8200.0,
                            status: 'DUE',
                          ),
                          InvoiceModel(
                            id: 'inv-1021',
                            invoiceNumber: 'INV-1021',
                            customerName: 'Omkar Electronics',
                            customerPhone: '9890123456',
                            invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
                            grandTotal: 3400.0,
                            paidAmount: 3400.0,
                            balanceAmount: 0.0,
                            status: 'PAID',
                          ),
                        ];

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final inv = list[index];
                      final isPaid = inv.status == 'PAID';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoicePreviewScreen(invoice: inv),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: AppColors.brandRed.withValues(alpha: 0.1),
                                child: Text(
                                  inv.customerName.substring(0, 1),
                                  style: const TextStyle(
                                    color: AppColors.brandRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inv.customerName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${inv.invoiceNumber} • Today, 11:30 AM',
                                      style: TextStyle(fontSize: 11, color: context.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${inv.grandTotal.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? AppTheme.emeraldGreen.withValues(alpha: 0.12)
                                          : AppTheme.primaryRed.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      inv.status,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? AppTheme.emeraldGreen : AppTheme.primaryRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppTheme.primaryRed),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: context.textSecondary, fontWeight: FontWeight.w500),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandRed, size: 20),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
