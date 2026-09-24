import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Purchase sample/mock data aligned with backend purchase models
  final List<Map<String, dynamic>> _purchases = [
    {
      'id': 'PO-1042',
      'supplier': 'National Textiles Ltd',
      'invoice': 'PUR-2026-089',
      'date': '24 Sep 2026',
      'amount': 42800.0,
      'status': 'RECEIVED',
      'tab': 'Purchases',
    },
    {
      'id': 'PO-1041',
      'supplier': 'Hindustan Distributors',
      'invoice': 'PUR-2026-088',
      'date': '23 Sep 2026',
      'amount': 18500.0,
      'status': 'PENDING',
      'tab': 'Purchase Orders',
    },
    {
      'id': 'PO-1040',
      'supplier': 'Vikas Raw Materials Co',
      'invoice': 'PUR-2026-085',
      'date': '22 Sep 2026',
      'amount': 31200.0,
      'status': 'RECEIVED',
      'tab': 'Purchases',
    },
    {
      'id': 'PO-1039',
      'supplier': 'Om Shakti Packaging',
      'invoice': 'RET-2026-004',
      'date': '21 Sep 2026',
      'amount': 4300.0,
      'status': 'RETURNED',
      'tab': 'Returns',
    },
    {
      'id': 'PO-1038',
      'supplier': 'Krishna Spices Wholesale',
      'invoice': 'PUR-2026-082',
      'date': '19 Sep 2026',
      'amount': 15600.0,
      'status': 'RECEIVED',
      'tab': 'Purchases',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showNewPurchaseDialog() {
    final supplierController = TextEditingController();
    final amountController = TextEditingController();
    final invoiceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Purchase Bill',
                  style: TextStyle(
                    fontSize: 18,
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
            const SizedBox(height: 16),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier Name',
                hintText: 'e.g. National Textiles Ltd',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: invoiceController,
              decoration: const InputDecoration(
                labelText: 'Supplier Bill / Invoice No.',
                hintText: 'e.g. BILL-9921',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Bill Amount (₹)',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (supplierController.text.trim().isNotEmpty && amountController.text.trim().isNotEmpty) {
                  final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                  setState(() {
                    _purchases.insert(0, {
                      'id': 'PO-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      'supplier': supplierController.text.trim(),
                      'invoice': invoiceController.text.trim().isEmpty ? 'PUR-${DateTime.now().day}' : invoiceController.text.trim(),
                      'date': 'Today',
                      'amount': amt,
                      'status': 'RECEIVED',
                      'tab': 'Purchases',
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Purchase entry added successfully!'),
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                  );
                }
              },
              child: const Text('Save Purchase Entry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Purchases',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: context.textSecondary, size: 20),
            tooltip: 'Filter',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.brandRed),
            tooltip: 'Add Purchase',
            onPressed: _showNewPurchaseDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryRed,
              indicatorWeight: 3,
              labelColor: AppTheme.primaryRed,
              unselectedLabelColor: context.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Purchase Orders'),
                Tab(text: 'Purchases'),
                Tab(text: 'Returns'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search supplier or bill number...',
                prefixIcon: Icon(Icons.search, size: 20, color: context.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                isDense: true,
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPurchaseList('Purchase Orders'),
                _buildPurchaseList('Purchases'),
                _buildPurchaseList('Returns'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showNewPurchaseDialog,
      ),
    );
  }

  Widget _buildPurchaseList(String tabName) {
    final filtered = _purchases.where((p) {
      final matchesTab = p['tab'] == tabName;
      final matchesSearch = _searchQuery.isEmpty ||
          (p['supplier'] as String).toLowerCase().contains(_searchQuery) ||
          (p['invoice'] as String).toLowerCase().contains(_searchQuery);
      return matchesTab && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 52, color: context.textMuted),
              const SizedBox(height: 12),
              Text(
                'No $tabName Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a purchase order or enter a supplier bill.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Entry'),
                onPressed: _showNewPurchaseDialog,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final amount = item['amount'] as double;
        final status = item['status'] as String;

        Color statusColor;
        Color statusBg;
        if (status == 'RECEIVED') {
          statusColor = AppTheme.emeraldGreen;
          statusBg = AppTheme.emeraldGreen.withValues(alpha: 0.12);
        } else if (status == 'RETURNED') {
          statusColor = AppTheme.primaryRed;
          statusBg = AppTheme.primaryRed.withValues(alpha: 0.12);
        } else {
          statusColor = AppTheme.amberGold;
          statusBg = AppTheme.amberGold.withValues(alpha: 0.12);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              // Supplier avatar initial
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.brandRed.withValues(alpha: 0.1),
                child: Text(
                  (item['supplier'] as String).substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.brandRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Supplier & Bill details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['supplier'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          item['invoice'],
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('•', style: TextStyle(fontSize: 10, color: context.textMuted)),
                        const SizedBox(width: 6),
                        Text(
                          item['date'],
                          style: TextStyle(fontSize: 11, color: context.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
