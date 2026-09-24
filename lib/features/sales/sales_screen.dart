import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/invoice_service.dart';
import 'invoice_preview_screen.dart';

final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final client = ref.watch(apiClientProvider);
  return InvoiceService(client);
});

final invoicesListProvider = FutureProvider.autoDispose<List<InvoiceModel>>((ref) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoices();
});

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sales',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: context.textSecondary, size: 20),
            tooltip: 'Filter Invoices',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.brandRed),
            tooltip: 'Create Invoice',
            onPressed: () => context.push('/sales/new'),
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
                Tab(text: 'Invoices'),
                Tab(text: 'Orders'),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search customer name or invoice #...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                isDense: true,
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvoicesTab(invoicesAsync),
                _buildMockOrdersTab(),
                _buildMockReturnsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/sales/new'),
      ),
    );
  }

  Widget _buildInvoicesTab(AsyncValue<List<InvoiceModel>> invoicesAsync) {
    return invoicesAsync.when(
      data: (invoices) {
        // If empty from backend, provide standard mock invoices for rich UX demonstration
        final displayList = invoices.isNotEmpty
            ? invoices
            : [
                InvoiceModel(
                  id: 'inv-01',
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
                  id: 'inv-02',
                  invoiceNumber: 'INV-1023',
                  customerName: 'Raj Enterprises',
                  customerPhone: '9822334455',
                  invoiceDate: DateTime.now().subtract(const Duration(days: 1)),
                  grandTotal: 14750.0,
                  paidAmount: 14750.0,
                  balanceAmount: 0.0,
                  status: 'PAID',
                ),
                InvoiceModel(
                  id: 'inv-03',
                  invoiceNumber: 'INV-1022',
                  customerName: 'City Supermarket',
                  customerPhone: '9422001122',
                  invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
                  grandTotal: 8200.0,
                  paidAmount: 0.0,
                  balanceAmount: 8200.0,
                  status: 'UNPAID',
                ),
                InvoiceModel(
                  id: 'inv-04',
                  invoiceNumber: 'INV-1021',
                  customerName: 'Modern General Store',
                  customerPhone: '9890123456',
                  invoiceDate: DateTime.now().subtract(const Duration(days: 4)),
                  grandTotal: 5600.0,
                  paidAmount: 3000.0,
                  balanceAmount: 2600.0,
                  status: 'PARTIAL',
                ),
              ];

        final filtered = displayList.where((inv) {
          final q = _searchQuery;
          return q.isEmpty ||
              inv.customerName.toLowerCase().contains(q) ||
              inv.invoiceNumber.toLowerCase().contains(q);
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 52, color: context.textMuted),
                const SizedBox(height: 12),
                Text('No invoices yet', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Create your first invoice to start tracking sales.', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => context.push('/sales/new'),
                  label: const Text('Create Invoice'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(invoicesListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final inv = filtered[index];
              final isPaid = inv.status == 'PAID';
              final isPartial = inv.status == 'PARTIAL';

              Color statusColor;
              Color statusBg;
              if (isPaid) {
                statusColor = AppTheme.emeraldGreen;
                statusBg = AppTheme.emeraldGreen.withValues(alpha: 0.12);
              } else if (isPartial) {
                statusColor = AppTheme.amberGold;
                statusBg = AppTheme.amberGold.withValues(alpha: 0.12);
              } else {
                statusColor = AppTheme.primaryRed;
                statusBg = AppTheme.primaryRed.withValues(alpha: 0.12);
              }

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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    children: [
                      // Customer Initial
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.brandRed.withValues(alpha: 0.1),
                        child: Text(
                          inv.customerName.isNotEmpty ? inv.customerName.substring(0, 1) : 'C',
                          style: const TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Customer & Invoice Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  inv.invoiceNumber,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('•', style: TextStyle(fontSize: 10, color: context.textMuted)),
                                const SizedBox(width: 6),
                                Text(
                                  '${inv.invoiceDate.day}/${inv.invoiceDate.month}/${inv.invoiceDate.year}',
                                  style: TextStyle(fontSize: 11, color: context.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Amount & Payment Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${inv.grandTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              inv.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
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
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error loading invoices: $e', style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.refresh(invoicesListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockOrdersTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        _buildOrderRow('ORD-881', 'Vikas Trading Co', 'Today', '₹6,400', 'CONFIRMED', AppTheme.emeraldGreen),
        _buildOrderRow('ORD-880', 'Modern Supermarket', 'Yesterday', '₹11,200', 'PACKING', AppTheme.amberGold),
        _buildOrderRow('ORD-879', 'Galaxy Departmental', '22 Sep 2026', '₹3,750', 'DELIVERED', Colors.blueAccent),
      ],
    );
  }

  Widget _buildMockReturnsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        _buildOrderRow('RET-104', 'Rahul Traders', 'Today', '₹1,200', 'CREDIT NOTE ISSUED', AppTheme.primaryRed),
        _buildOrderRow('RET-103', 'City Supermarket', '20 Sep 2026', '₹850', 'RESTOCKED', AppTheme.emeraldGreen),
      ],
    );
  }

  Widget _buildOrderRow(String id, String party, String date, String amt, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(party, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimary)),
              const SizedBox(height: 2),
              Text('$id • $date', style: TextStyle(fontSize: 11, color: context.textSecondary)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amt, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimary)),
              const SizedBox(height: 2),
              Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
