import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/customer_service.dart';
import '../../services/product_service.dart';
import 'sales_screen.dart';

final customerServiceProvider = Provider<CustomerService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomerService(client);
});

final productServiceProvider = Provider<ProductService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductService(client);
});

final customersFutureProvider = FutureProvider.autoDispose<List<CustomerModel>>((ref) async {
  return ref.watch(customerServiceProvider).getCustomers();
});

final productsFutureProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  return ref.watch(productServiceProvider).getProducts();
});

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  CustomerModel? _selectedCustomer;
  final List<Map<String, dynamic>> _selectedItems = [];
  bool _submitting = false;

  void _addItem(ProductModel product) {
    setState(() {
      final existingIndex = _selectedItems.indexWhere((i) => i['product'].id == product.id);
      if (existingIndex >= 0) {
        _selectedItems[existingIndex]['quantity'] += 1;
      } else {
        _selectedItems.add({
          'product': product,
          'quantity': 1,
        });
      }
    });
  }

  double get _totalAmount {
    double total = 0;
    for (var item in _selectedItems) {
      final p = item['product'] as ProductModel;
      final q = item['quantity'] as int;
      final lineSubtotal = p.sellingPrice * q;
      final tax = (lineSubtotal * p.gstRate) / 100;
      total += lineSubtotal + tax;
    }
    return total;
  }

  Future<void> _submitInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final itemsPayload = _selectedItems.map((item) {
        final p = item['product'] as ProductModel;
        return {
          'productId': p.id,
          'quantity': item['quantity'],
          'unitPrice': p.sellingPrice,
          'gstRate': p.gstRate,
        };
      }).toList();

      await ref.read(invoiceServiceProvider).createInvoice(
            customerId: _selectedCustomer!.id,
            items: itemsPayload,
            initialPayment: {
              'amount': _totalAmount,
              'paymentMethod': 'CASH',
            },
          );

      ref.invalidate(dashboardMetricsProvider);
      ref.invalidate(invoicesListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice created & stock updated successfully!'),
            backgroundColor: AppTheme.emeraldGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersFutureProvider);
    final productsAsync = ref.watch(productsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Sale', style: TextStyle(color: context.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Select Customer
            Text(
              'Select Customer',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            customersAsync.when(
              data: (customers) => DropdownButtonFormField<CustomerModel>(
                initialValue: _selectedCustomer,
                dropdownColor: context.surfaceColor,
                hint: Text('Choose Customer', style: TextStyle(color: context.textMuted, fontSize: 13)),
                items: customers
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.name} (${c.phone})', style: TextStyle(fontSize: 13, color: context.textPrimary)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCustomer = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading customers: $e', style: const TextStyle(color: AppColors.error)),
            ),
            const SizedBox(height: 20),

            // Select Products
            Text(
              'Available Catalog Products',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            productsAsync.when(
              data: (products) => SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return InkWell(
                      onTap: () => _addItem(p),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: context.textPrimary),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${p.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
                                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading products: $e', style: const TextStyle(color: AppColors.error)),
            ),
            const SizedBox(height: 20),

            // Selected Items
            Text(
              'Cart Items',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            if (_selectedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Center(
                  child: Text('Tap products above to add to cart', style: TextStyle(color: context.textMuted, fontSize: 12)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _selectedItems[index];
                  final p = item['product'] as ProductModel;
                  final q = item['quantity'] as int;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: context.textPrimary, fontSize: 12)),
                              Text('₹${p.sellingPrice.toStringAsFixed(0)} + ${p.gstRate}% GST', style: TextStyle(color: context.textSecondary, fontSize: 10)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, size: 18, color: context.textPrimary),
                              onPressed: () {
                                setState(() {
                                  if (q > 1) {
                                    item['quantity'] -= 1;
                                  } else {
                                    _selectedItems.removeAt(index);
                                  }
                                });
                              },
                            ),
                            Text('$q', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimary)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.brandRed),
                              onPressed: () {
                                setState(() {
                                  item['quantity'] += 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Total Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.5)),
                boxShadow: context.isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.brandRed.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total with Tax:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimary)),
                  Text(
                    '₹${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.emeraldGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _submitting ? null : _submitInvoice,
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Complete Sale & Generate Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
