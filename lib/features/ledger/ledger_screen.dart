import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  String _selectedParty = 'Rahul Traders';
  double _currentDue = 12500.0;

  final List<String> _parties = [
    'Rahul Traders',
    'Raj Enterprises',
    'City Supermarket',
    'National Textiles Ltd',
    'Om Shakti Packaging',
  ];

  final List<Map<String, dynamic>> _ledgerEntries = [
    {
      'date': '24 Sep 2026',
      'title': 'Invoice INV-1024',
      'amount': 5000.0,
      'isDebit': true,
      'balance': 12500.0,
    },
    {
      'date': '23 Sep 2026',
      'title': 'Payment Received (UPI)',
      'amount': 3000.0,
      'isDebit': false,
      'balance': 7500.0,
    },
    {
      'date': '18 Sep 2026',
      'title': 'Invoice INV-1018',
      'amount': 6500.0,
      'isDebit': true,
      'balance': 10500.0,
    },
    {
      'date': '10 Sep 2026',
      'title': 'Payment Received (Cash)',
      'amount': 4000.0,
      'isDebit': false,
      'balance': 4000.0,
    },
    {
      'date': '01 Sep 2026',
      'title': 'Opening Balance',
      'amount': 8000.0,
      'isDebit': true,
      'balance': 8000.0,
    },
  ];

  void _showRecordPaymentDialog() {
    final amtCtrl = TextEditingController();
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
                  'Record Khata Payment',
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
              'Party: $_selectedParty',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Amount Received (₹)',
                hintText: '0.00',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amt > 0) {
                  setState(() {
                    _currentDue = (_currentDue - amt).clamp(0, double.infinity);
                    _ledgerEntries.insert(0, {
                      'date': 'Today',
                      'title': 'Payment Received (Quick)',
                      'amount': amt,
                      'isDebit': false,
                      'balance': _currentDue,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment of ₹$amt recorded in Khata!'),
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                  );
                }
              },
              child: const Text('Save Payment to Khata'),
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
          'Khata / Ledger',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 20),
            tooltip: 'Print Statement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Khata statement downloaded as PDF.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Party Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.surfaceColor,
            child: Row(
              children: [
                Text(
                  'Select Party:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedParty,
                      dropdownColor: context.surfaceColor,
                      isExpanded: true,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimary),
                      items: _parties
                          .map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(color: context.textPrimary))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedParty = val;
                            _currentDue = val == 'Rahul Traders' ? 12500.0 : 4200.0;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Total Due Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(bottom: BorderSide(color: context.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Balance Due',
                      style: TextStyle(fontSize: 12, color: context.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_currentDue.toStringAsFixed(0)} Due',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: _showRecordPaymentDialog,
                ),
              ],
            ),
          ),

          // Timeline Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Timeline',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
                ),
                Text(
                  'Debit (+) / Credit (-)',
                  style: TextStyle(fontSize: 11, color: context.textMuted),
                ),
              ],
            ),
          ),

          // Timeline List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _ledgerEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = _ledgerEntries[index];
                final isDebit = entry['isDebit'] as bool;
                final amount = entry['amount'] as double;
                final balance = entry['balance'] as double;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    children: [
                      // Status Dot & Indicator
                      Container(
                        width: 8,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDebit ? AppTheme.primaryRed : AppTheme.emeraldGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry['date'],
                              style: TextStyle(fontSize: 11, color: context.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isDebit ? "+" : "-"}₹${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDebit ? AppTheme.primaryRed : AppTheme.emeraldGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Balance: ₹${balance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
