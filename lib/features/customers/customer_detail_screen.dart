import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../sales/sales_screen.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double _currentBalance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentBalance = widget.customer.currentBalance;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showReceivePaymentDialog() {
    final amtCtrl = TextEditingController();
    final refNumCtrl = TextEditingController();
    String selectedMode = 'UPI';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                    'Receive Payment',
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
              const SizedBox(height: 12),
              Text(
                'Party: ${widget.customer.name}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Amount Received (₹) *',
                  hintText: '0.00',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selectedMode,
                dropdownColor: context.surfaceColor,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: ['UPI', 'Cash', 'Bank Transfer', 'Cheque']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: context.textPrimary))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setSheetState(() => selectedMode = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refNumCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reference Number (UTR / Ref)',
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount')),
                          );
                          return;
                        }

                        setSheetState(() => isSubmitting = true);
                        final messenger = ScaffoldMessenger.of(context);

                        String backendMethod = 'CASH';
                        if (selectedMode == 'UPI') backendMethod = 'UPI';
                        if (selectedMode == 'Bank Transfer') backendMethod = 'BANK_TRANSFER';
                        if (selectedMode == 'Cheque') backendMethod = 'CHEQUE';

                        try {
                          await ref.read(paymentServiceProvider).createPayment(
                                partyType: 'CUSTOMER',
                                customerId: widget.customer.id,
                                amount: amt,
                                paymentMethod: backendMethod,
                                referenceNumber: refNumCtrl.text.trim().isNotEmpty ? refNumCtrl.text.trim() : null,
                              );

                          ref.invalidate(customerLedgerProvider(widget.customer.id));
                          ref.invalidate(customersFutureProvider);
                          ref.invalidate(paymentsFutureProvider);
                          ref.invalidate(dashboardMetricsProvider);

                          setState(() {
                            _currentBalance = (_currentBalance - amt).clamp(0, double.infinity);
                          });

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
                    : const Text('Record Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    final hasDue = _currentBalance > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          c.name,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            tooltip: 'Share Statement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer ledger statement exported.')),
              );
            },
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
                Tab(text: 'Overview'),
                Tab(text: 'Sales'),
                Tab(text: 'Payments'),
                Tab(text: 'Ledger'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Outstanding & Quick Contact Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(bottom: BorderSide(color: context.borderColor)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding Balance',
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_currentBalance.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: hasDue ? AppTheme.amberGold : AppTheme.emeraldGreen,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (hasDue ? AppTheme.amberGold : AppTheme.emeraldGreen).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hasDue ? 'Payment Due' : 'All Clear',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasDue ? AppTheme.amberGold : AppTheme.emeraldGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.call,
                        label: 'Call',
                        color: Colors.blueAccent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${c.phone}...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        color: AppTheme.emeraldGreen,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening WhatsApp for ${c.phone}...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.receipt_long,
                        label: 'Invoice',
                        color: AppColors.brandRed,
                        onTap: () => context.push('/sales/new'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.payments_outlined,
                        label: 'Pay',
                        color: Colors.purpleAccent,
                        onTap: _showReceivePaymentDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSalesTab(),
                _buildPaymentsTab(),
                _buildLedgerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final c = widget.customer;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Party Profile',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Phone Number', c.phone),
              const Divider(height: 16),
              _buildDetailRow('Email Address', c.email ?? 'Not provided'),
              const Divider(height: 16),
              _buildDetailRow('Billing City / State', '${c.city ?? "Pune"}, Maharashtra'),
              const Divider(height: 16),
              _buildDetailRow('GSTIN Number', c.gstin ?? 'Unregistered Consumer'),
              const Divider(height: 16),
              _buildDetailRow('Credit Limit', '₹50,000'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTab() {
    final invoicesAsync = ref.watch(invoicesListProvider);

    return invoicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
      error: (err, stack) => Center(child: Text('Failed to load invoices', style: TextStyle(color: context.textSecondary))),
      data: (invoices) {
        final custInvoices = invoices.where((inv) {
          return inv.customerName.toLowerCase() == widget.customer.name.toLowerCase() ||
              (inv.customerPhone.isNotEmpty && inv.customerPhone == widget.customer.phone);
        }).toList();

        if (custInvoices.isEmpty) {
          return Center(
            child: Text('No sales invoices for this client yet.', style: TextStyle(color: context.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: custInvoices.length,
          itemBuilder: (context, index) {
            final inv = custInvoices[index];
            final formattedDate =
                '${inv.invoiceDate.day.toString().padLeft(2, '0')}/${inv.invoiceDate.month.toString().padLeft(2, '0')}/${inv.invoiceDate.year}';
            final isPaid = inv.status == 'PAID';

            return _buildTransactionRow(
              title: 'Invoice ${inv.invoiceNumber}',
              date: formattedDate,
              amount: '₹${inv.grandTotal.toStringAsFixed(0)}',
              status: inv.status,
              statusColor: isPaid ? AppTheme.emeraldGreen : AppTheme.primaryRed,
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    final paymentsAsync = ref.watch(paymentsFutureProvider);

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
      error: (err, stack) => Center(child: Text('Failed to load payments', style: TextStyle(color: context.textSecondary))),
      data: (payments) {
        final custPayments = payments.where((p) {
          return p.partyName.toLowerCase() == widget.customer.name.toLowerCase();
        }).toList();

        if (custPayments.isEmpty) {
          return Center(
            child: Text('No recorded payments for this customer.', style: TextStyle(color: context.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: custPayments.length,
          itemBuilder: (context, index) {
            final p = custPayments[index];
            final formattedDate =
                '${p.paymentDate.day.toString().padLeft(2, '0')}/${p.paymentDate.month.toString().padLeft(2, '0')}/${p.paymentDate.year}';

            return _buildTransactionRow(
              title: 'Payment Received (${p.paymentMethod})',
              date: formattedDate,
              amount: '₹${p.amount.toStringAsFixed(0)}',
              status: 'COMPLETED',
              statusColor: AppTheme.emeraldGreen,
            );
          },
        );
      },
    );
  }

  Widget _buildLedgerTab() {
    final ledgerAsync = ref.watch(customerLedgerProvider(widget.customer.id));

    return ledgerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
      error: (err, stack) => Center(child: Text('Failed to load ledger', style: TextStyle(color: context.textSecondary))),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text('No ledger entries recorded yet.', style: TextStyle(color: context.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final dateStr = entry['date'] != null
                ? DateTime.parse(entry['date']).toLocal().toString().split(' ')[0]
                : 'Recent';
            final desc = entry['description'] ?? entry['referenceType'] ?? 'Transaction';
            final amt = (entry['amount'] as num?)?.toDouble() ?? 0.0;
            final isDebit = entry['entryType'] == 'DEBIT';
            final balanceAfter = (entry['balanceAfter'] as num?)?.toDouble() ?? 0.0;

            return _buildLedgerEntry(
              date: dateStr,
              type: desc,
              amount: '${isDebit ? "+" : "-"}₹${amt.toStringAsFixed(0)}',
              runningBalance: '₹${balanceAfter.toStringAsFixed(0)}',
              isDebit: isDebit,
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary)),
      ],
    );
  }

  Widget _buildTransactionRow({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerEntry({
    required String date,
    required String type,
    required String amount,
    required String runningBalance,
    required bool isDebit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDebit ? AppTheme.primaryRed : AppTheme.emeraldGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Bal: $runningBalance',
                style: TextStyle(
                  fontSize: 10,
                  color: context.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
