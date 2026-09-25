import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/payment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/dashboard_provider.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const PaymentsScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showRecordPaymentDialog() {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final refNumCtrl = TextEditingController();
    String type = 'Received'; // 'Received' (IN) | 'Paid' (OUT)
    String method = 'UPI';
    String? selectedCustomerId;
    String? selectedSupplierId;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final customers = ref.watch(customersFutureProvider).valueOrNull ?? [];
          final suppliers = ref.watch(suppliersFutureProvider).valueOrNull ?? [];

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
                        'Record Payment',
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Payment In (Received)')),
                          selected: type == 'Received',
                          selectedColor: AppTheme.emeraldGreen,
                          onSelected: (_) => setSheetState(() {
                            type = 'Received';
                            selectedSupplierId = null;
                          }),
                          labelStyle: TextStyle(
                            color: type == 'Received' ? Colors.white : context.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Payment Out (Paid)')),
                          selected: type == 'Paid',
                          selectedColor: AppTheme.primaryRed,
                          onSelected: (_) => setSheetState(() {
                            type = 'Paid';
                            selectedCustomerId = null;
                          }),
                          labelStyle: TextStyle(
                            color: type == 'Paid' ? Colors.white : context.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (type == 'Received') ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedCustomerId,
                      dropdownColor: context.surfaceColor,
                      decoration: const InputDecoration(labelText: 'Select Customer *'),
                      items: customers
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.name} (${c.phone})', style: TextStyle(color: context.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (val) => setSheetState(() => selectedCustomerId = val),
                    ),
                  ] else ...[
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
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹) *',
                      hintText: '0.00',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: method,
                    dropdownColor: context.surfaceColor,
                    decoration: const InputDecoration(labelText: 'Payment Method'),
                    items: ['UPI', 'Cash', 'Bank Transfer', 'Cheque']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: context.textPrimary))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => method = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: refNumCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reference # (UPI / Cheque / UTR)',
                      hintText: 'Optional reference',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                            if (amt <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid amount')),
                              );
                              return;
                            }

                            if (type == 'Received' && selectedCustomerId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a customer')),
                              );
                              return;
                            }

                            if (type == 'Paid' && selectedSupplierId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a supplier')),
                              );
                              return;
                            }

                            setSheetState(() => isSubmitting = true);
                            final messenger = ScaffoldMessenger.of(context);

                            String backendMethod = 'CASH';
                            if (method == 'UPI') backendMethod = 'UPI';
                            if (method == 'Bank Transfer') backendMethod = 'BANK_TRANSFER';
                            if (method == 'Cheque') backendMethod = 'CHEQUE';

                            try {
                              await ref.read(paymentServiceProvider).createPayment(
                                    partyType: type == 'Received' ? 'CUSTOMER' : 'SUPPLIER',
                                    customerId: selectedCustomerId,
                                    supplierId: selectedSupplierId,
                                    amount: amt,
                                    paymentMethod: backendMethod,
                                    referenceNumber: refNumCtrl.text.trim().isNotEmpty ? refNumCtrl.text.trim() : null,
                                    notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                                  );

                              ref.invalidate(paymentsFutureProvider);
                              ref.invalidate(customersFutureProvider);
                              ref.invalidate(suppliersFutureProvider);
                              ref.invalidate(dashboardMetricsProvider);

                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Payment of ₹$amt recorded successfully!'),
                                    backgroundColor: AppTheme.emeraldGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              setSheetState(() => isSubmitting = false);
                              if (mounted) {
                                messenger.showSnackBar(
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
                        : const Text('Save Payment Entry'),
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
          'Payments',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.brandRed),
            tooltip: 'Record Payment',
            onPressed: _showRecordPaymentDialog,
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
                Tab(text: 'Received (In)'),
                Tab(text: 'Paid (Out)'),
                Tab(text: 'All Payments'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search payments by party or method...',
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList('Received'),
                _buildTransactionList('Paid'),
                _buildTransactionList('All'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showRecordPaymentDialog,
      ),
    );
  }

  Widget _buildTransactionList(String tabKey) {
    final paymentsAsync = ref.watch(paymentsFutureProvider);

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load payments', style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(paymentsFutureProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (payments) {
        final filtered = payments.where((t) {
          final isReceived = t.type == 'IN' || t.partyType == 'CUSTOMER';
          final matchesTab = tabKey == 'All'
              ? true
              : tabKey == 'Received'
                  ? isReceived
                  : !isReceived;

          final q = _searchQuery.toLowerCase();
          final matchesSearch = _searchQuery.isEmpty ||
              t.partyName.toLowerCase().contains(q) ||
              t.paymentMethod.toLowerCase().contains(q) ||
              (t.referenceNumber?.toLowerCase().contains(q) ?? false);
          return matchesTab && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(paymentsFutureProvider),
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment, size: 48, color: context.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No $tabKey payments',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Entries will show here once recorded.',
                          style: TextStyle(color: context.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Record Payment'),
                          onPressed: _showRecordPaymentDialog,
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
          onRefresh: () async => ref.refresh(paymentsFutureProvider),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = filtered[index];
              final isReceived = t.type == 'IN' || t.partyType == 'CUSTOMER';
              final formattedDate =
                  '${t.paymentDate.day.toString().padLeft(2, '0')}/${t.paymentDate.month.toString().padLeft(2, '0')}/${t.paymentDate.year}';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isReceived
                            ? AppTheme.emeraldGreen.withValues(alpha: 0.12)
                            : AppTheme.primaryRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isReceived ? Icons.call_received : Icons.call_made,
                        size: 20,
                        color: isReceived ? AppTheme.emeraldGreen : AppTheme.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.partyName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                t.paymentMethod,
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
                          '${isReceived ? "+" : "-"}₹${t.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isReceived ? AppTheme.emeraldGreen : AppTheme.primaryRed,
                          ),
                        ),
                        if (t.referenceNumber != null && t.referenceNumber!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            t.referenceNumber!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: context.textMuted,
                            ),
                          ),
                        ],
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
