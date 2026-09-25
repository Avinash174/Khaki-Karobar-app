import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/dashboard_provider.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    String? selectedSupplierId;
    String? selectedProductId;
    final qtyController = TextEditingController(text: '10');
    final rateController = TextEditingController(text: '100');
    final paidController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final suppliers = ref.watch(suppliersFutureProvider).valueOrNull ?? [];
          final products = ref.watch(productsFutureProvider).valueOrNull ?? [];

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedSupplierId,
                    dropdownColor: context.surfaceColor,
                    decoration: const InputDecoration(labelText: 'Select Supplier *'),
                    items: suppliers
                        .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.name} (${s.phone})', style: TextStyle(color: context.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (val) => setSheetState(() => selectedSupplierId = val),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedProductId,
                    dropdownColor: context.surfaceColor,
                    decoration: const InputDecoration(labelText: 'Select Inward Product *'),
                    items: products
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} (Stock: ${p.currentStock})', style: TextStyle(color: context.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setSheetState(() {
                        selectedProductId = val;
                        final prod = products.firstWhere((p) => p.id == val, orElse: () => products.first);
                        rateController.text = prod.purchasePrice.toStringAsFixed(0);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity *',
                            hintText: '10',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: rateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Unit Rate (₹) *',
                            hintText: '0.00',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: paidController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Initial Paid Amount (₹)',
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase / Bill Notes',
                      hintText: 'e.g. Inward batch #41',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (selectedSupplierId == null || selectedProductId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select supplier and product')),
                              );
                              return;
                            }

                            final qty = double.tryParse(qtyController.text.trim()) ?? 0;
                            final rate = double.tryParse(rateController.text.trim()) ?? 0;
                            final paid = double.tryParse(paidController.text.trim()) ?? 0;

                            if (qty <= 0 || rate <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter valid quantity and rate')),
                              );
                              return;
                            }

                            setSheetState(() => isSubmitting = true);

                            try {
                              await ref.read(purchaseServiceProvider).createPurchase(
                                    supplierId: selectedSupplierId!,
                                    items: [
                                      {
                                        'productId': selectedProductId!,
                                        'quantity': qty,
                                        'unitPrice': rate,
                                        'gstRate': 18,
                                      }
                                    ],
                                    paidAmount: paid,
                                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                                  );

                              ref.invalidate(purchasesFutureProvider);
                              ref.invalidate(suppliersFutureProvider);
                              ref.invalidate(productsFutureProvider);
                              ref.invalidate(dashboardMetricsProvider);

                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Purchase entry added successfully!'),
                                    backgroundColor: AppTheme.emeraldGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              setSheetState(() => isSubmitting = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: AppTheme.primaryRed,
                                  ),
                                );
                              }
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Purchase Entry'),
                  ),
                ],
              ),
            ),
          );
        },
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
                Tab(text: 'All Purchases'),
                Tab(text: 'Pending'),
                Tab(text: 'Paid'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPurchaseList('All'),
                _buildPurchaseList('Pending'),
                _buildPurchaseList('Paid'),
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
    final purchasesAsync = ref.watch(purchasesFutureProvider);

    return purchasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load purchases', style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(purchasesFutureProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (purchases) {
        final filtered = purchases.where((p) {
          final matchesTab = tabName == 'All'
              ? true
              : tabName == 'Paid'
                  ? p.status == 'PAID'
                  : p.status != 'PAID';

          final matchesSearch = _searchQuery.isEmpty ||
              p.supplierName.toLowerCase().contains(_searchQuery) ||
              p.purchaseNumber.toLowerCase().contains(_searchQuery);
          return matchesTab && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(purchasesFutureProvider),
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 52, color: context.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No Purchases Found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create a purchase entry or enter a supplier inward bill.',
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
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(purchasesFutureProvider),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = filtered[index];
              final amount = item.grandTotal;
              final status = item.status;
              final formattedDate =
                  '${item.purchaseDate.day.toString().padLeft(2, '0')}/${item.purchaseDate.month.toString().padLeft(2, '0')}/${item.purchaseDate.year}';

              Color statusColor;
              Color statusBg;
              if (status == 'PAID' || status == 'RECEIVED') {
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.indigo, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.supplierName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                item.purchaseNumber,
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
                                formattedDate,
                                style: TextStyle(fontSize: 11, color: context.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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
                              fontSize: 10,
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
          ),
        );
      },
    );
  }
}
