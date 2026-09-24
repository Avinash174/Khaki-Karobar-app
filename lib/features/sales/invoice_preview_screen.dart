import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import 'sales_screen.dart';

class InvoicePreviewScreen extends ConsumerWidget {
  final InvoiceModel invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isPaid = invoice.status == 'PAID';
    final businessName = authState.activeBusiness?.name ?? 'Khaki General Store';
    final gstin = authState.activeBusiness?.gstin ?? '27AAAAA0000A1Z5';

    final subtotal = invoice.grandTotal / 1.18;
    final gst = invoice.grandTotal - subtotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tax Invoice #${invoice.invoiceNumber}',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            tooltip: 'Share Invoice',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing invoice link...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Printable Bill Container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Business Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              businessName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Khaki Karobar Merchant', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                            Text('GSTIN: $gstin', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                            Text('Phone: ${authState.activeBusiness?.phone ?? "+91 9876543210"}', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid ? AppTheme.emeraldGreen.withValues(alpha: 0.12) : AppTheme.amberGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPaid ? AppTheme.emeraldGreen.withValues(alpha: 0.4) : AppTheme.amberGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          isPaid ? 'PAID' : 'DUE / UNPAID',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isPaid ? AppTheme.emeraldGreen : AppTheme.amberGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Bill To & Invoice Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BILL TO:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMuted)),
                            const SizedBox(height: 3),
                            Text(
                              invoice.customerName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimary),
                            ),
                            Text(
                              invoice.customerPhone.isNotEmpty ? invoice.customerPhone : 'Phone: +91 9876543211',
                              style: TextStyle(fontSize: 12, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('INVOICE DETAILS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMuted)),
                          const SizedBox(height: 3),
                          Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                          ),
                          Text(
                            '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
                            style: TextStyle(fontSize: 12, color: context.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Products Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 5, child: Text('ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMuted))),
                        Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMuted))),
                        Expanded(flex: 3, child: Text('PRICE', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMuted))),
                        Expanded(flex: 3, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMuted))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Rows
                  _buildItemRow('Standard Catalog Goods', '1', '₹${subtotal.toStringAsFixed(0)}', '₹${subtotal.toStringAsFixed(0)}'),
                  _buildItemRow('Packaging & Handling', '1', '₹0', '₹0'),

                  const Divider(height: 24),

                  // Calculation Breakdown
                  _buildSummaryLine('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _buildSummaryLine('Discount', '₹0.00'),
                  const SizedBox(height: 6),
                  _buildSummaryLine('CGST + SGST (18%)', '₹${gst.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _buildSummaryLine('Round Off', '₹0.00'),
                  const Divider(height: 18),

                  // Grand Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${invoice.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Footer note & branding
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.isDarkMode ? Colors.white24 : Colors.grey.shade300,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Thank you for your business! • Powered by Khaki Karobar',
                          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: context.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (WhatsApp, Share, PDF, Print)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await ref.read(invoiceServiceProvider).shareWhatsApp(invoice.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('WhatsApp invoice dispatched to customer!')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF invoice saved to Downloads.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Print Receipt'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connecting to Bluetooth Thermal Printer...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share Link'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invoice link copied to clipboard.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String item, String qty, String price, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text(qty, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 3, child: Text(price, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 3, child: Text(total, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
