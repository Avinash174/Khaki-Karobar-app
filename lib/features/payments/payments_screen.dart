import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

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

  final List<Map<String, dynamic>> _transactions = [
    {
      'party': 'Rahul Traders',
      'type': 'Received',
      'date': 'Today, 11:30 AM',
      'amount': 4500.0,
      'method': 'UPI',
      'status': 'Completed',
      'tab': 'Received',
    },
    {
      'party': 'National Textiles Ltd',
      'type': 'Paid',
      'date': 'Today, 09:15 AM',
      'amount': 15000.0,
      'method': 'Bank Transfer',
      'status': 'Completed',
      'tab': 'Paid',
    },
    {
      'party': 'Raj Enterprises',
      'type': 'Received',
      'date': 'Yesterday',
      'amount': 14750.0,
      'method': 'Cash',
      'status': 'Completed',
      'tab': 'Received',
    },
    {
      'party': 'Vikas Raw Materials Co',
      'type': 'Paid',
      'date': '22 Sep 2026',
      'amount': 12000.0,
      'method': 'Cheque #4012',
      'status': 'Completed',
      'tab': 'Paid',
    },
    {
      'party': 'City Supermarket',
      'type': 'Received',
      'date': '20 Sep 2026',
      'amount': 8200.0,
      'method': 'UPI / QR',
      'status': 'Pending Verification',
      'tab': 'Pending',
    },
    {
      'party': 'Apex Commodities',
      'type': 'Paid',
      'date': '19 Sep 2026',
      'amount': 25000.0,
      'method': 'RTGS',
      'status': 'Processing',
      'tab': 'Pending',
    },
  ];

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
    final partyCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'Received';
    String method = 'UPI';

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
                      onSelected: (_) => setSheetState(() => type = 'Received'),
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
                      onSelected: (_) => setSheetState(() => type = 'Paid'),
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
              TextField(
                controller: partyCtrl,
                decoration: InputDecoration(
                  labelText: type == 'Received' ? 'Customer / Party Name' : 'Supplier / Vendor Name',
                  hintText: 'e.g. Rahul Traders',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: '0.00',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                dropdownColor: context.surfaceColor,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['UPI', 'Cash', 'Bank Transfer (NEFT/IMPS)', 'Cheque', 'Card']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: context.textPrimary))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setSheetState(() => method = val);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (partyCtrl.text.trim().isNotEmpty && amt > 0) {
                    setState(() {
                      _transactions.insert(0, {
                        'party': partyCtrl.text.trim(),
                        'type': type,
                        'date': 'Just now',
                        'amount': amt,
                        'method': method,
                        'status': 'Completed',
                        'tab': type,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment of ₹$amt recorded successfully!'),
                        backgroundColor: AppTheme.emeraldGreen,
                      ),
                    );
                  }
                },
                child: const Text('Save Payment Entry'),
              ),
            ],
          ),
        ),
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
                Tab(text: 'Pending'),
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
                _buildTransactionList('Pending'),
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
    final filtered = _transactions.where((t) {
      final matchesTab = t['tab'] == tabKey;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          (t['party'] as String).toLowerCase().contains(q) ||
          (t['method'] as String).toLowerCase().contains(q);
      return matchesTab && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
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
              Text('Entries will show here once recorded.', style: TextStyle(color: context.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Payment'),
                onPressed: _showRecordPaymentDialog,
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
        final t = filtered[index];
        final amount = t['amount'] as double;
        final isReceived = t['type'] == 'Received';

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
                      t['party'],
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
                          t['method'],
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
                          t['date'],
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
                    '${isReceived ? "+" : "-"}₹${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isReceived ? AppTheme.emeraldGreen : AppTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: context.textMuted,
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
