import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/invoice_service.dart';

final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final client = ref.watch(apiClientProvider);
  return InvoiceService(client);
});

final invoicesListProvider = FutureProvider.autoDispose<List<InvoiceModel>>((ref) async {
  final service = ref.watch(invoiceServiceProvider);
  return service.getInvoices();
});

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Invoices', style: TextStyle(color: context.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.textPrimary),
            onPressed: () => context.push('/sales/new'),
          ),
        ],
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: context.textMuted),
                  const SizedBox(height: 16),
                  Text('No invoices recorded yet', style: TextStyle(color: context.textPrimary, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.push('/sales/new'),
                    child: const Text('+ Create First Sale'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(invoicesListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final inv = invoices[index];
                final isPaid = inv.status == 'PAID';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderColor),
                    boxShadow: context.isDarkMode
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.invoiceNumber,
                            style: TextStyle(fontWeight: FontWeight.bold, color: context.textPrimary, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inv.customerName,
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid ? AppTheme.emeraldGreen.withValues(alpha: 0.15) : AppTheme.amberGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              inv.status,
                              style: TextStyle(
                                color: isPaid ? AppTheme.emeraldGreen : AppTheme.amberGold,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${inv.grandTotal.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              await ref.read(invoiceServiceProvider).shareWhatsApp(inv.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('WhatsApp invoice dispatched!')),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.send, size: 10, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('WhatsApp', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed)),
        error: (e, _) => Center(child: Text('Error loading invoices: $e', style: const TextStyle(color: AppColors.error))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: () => context.push('/sales/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
