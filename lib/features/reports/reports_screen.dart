import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportCategories = [
      {
        'title': 'Sales Reports',
        'desc': 'Daily sales, item-wise sales, customer sales summary',
        'icon': Icons.point_of_sale,
        'color': AppTheme.emeraldGreen,
      },
      {
        'title': 'Purchase Reports',
        'desc': 'Supplier bills, purchase orders, vendor item analysis',
        'icon': Icons.shopping_bag_outlined,
        'color': Colors.blueAccent,
      },
      {
        'title': 'Inventory Reports',
        'desc': 'Stock summary, low-stock alerts, stock valuation',
        'icon': Icons.inventory_2_outlined,
        'color': AppTheme.amberGold,
      },
      {
        'title': 'GST & Tax Reports',
        'desc': 'GSTR-1, GSTR-3B, Tax liability & input credit breakdown',
        'icon': Icons.receipt_long,
        'color': Colors.purpleAccent,
      },
      {
        'title': 'Profit & Loss',
        'desc': 'Net income, gross margins, operating expenses & revenue',
        'icon': Icons.trending_up,
        'color': AppColors.brandRed,
      },
      {
        'title': 'Outstanding Dues',
        'desc': 'Receivables from customers and payables owed to vendors',
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.orangeAccent,
      },
      {
        'title': 'Customer Reports',
        'desc': 'Customer statements, party aging and transaction log',
        'icon': Icons.people_outline,
        'color': Colors.teal,
      },
      {
        'title': 'Payment Reports',
        'desc': 'Cash flow, UPI collections, bank deposits and cheques',
        'icon': Icons.payments_outlined,
        'color': Colors.indigoAccent,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 22),
            tooltip: 'Export All Reports',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading consolidated Excel report...')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: reportCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final r = reportCategories[index];
          final color = r['color'] as Color;

          return InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Generating ${r['title']}...')),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(r['icon'] as IconData, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          r['desc'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: context.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
