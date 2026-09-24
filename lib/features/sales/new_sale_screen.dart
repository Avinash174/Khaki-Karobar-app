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
  double _discountPercent = 0.0;
  String _productSearchQuery = '';

  void _addItem(ProductModel product) {
    setState(() {
      final existingIndex = _selectedItems.indexWhere((i) => i['product'].id == product.id);
      if (existingIndex >= 0) {
        _selectedItems[existingIndex]['quantity'] += 1;
      } else {
        _selectedItems.add({
          'product': product,
          'quantity': 1,
          'discount': 0.0,
        });
      }
    });
  }

  double get _subtotal {
    double sub = 0;
    for (var item in _selectedItems) {
      final p = item['product'] as ProductModel;
      final q = item['quantity'] as int;
      sub += p.sellingPrice * q;
    }
    return sub;
  }

  double get _discountAmount => (_subtotal * _discountPercent) / 100;

  double get _gstTotal {
    double gst = 0;
    for (var item in _selectedItems) {
      final p = item['product'] as ProductModel;
      final q = item['quantity'] as int;
      final lineSub = p.sellingPrice * q;
      gst += (lineSub * p.gstRate) / 100;
    }
    return gst;
  }

  double get _rawGrandTotal => _subtotal - _discountAmount + _gstTotal;

  double get _roundOff => (_rawGrandTotal.roundToDouble() - _rawGrandTotal);

  double get _grandTotal => _rawGrandTotal.roundToDouble();

  Future<void> _submitInvoice({bool shareAfter = false}) async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a customer to proceed.'),
          backgroundColor: AppColors.brandRed,
        ),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product to the invoice.'),
          backgroundColor: AppColors.brandRed,
        ),
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

      final result = await ref.read(invoiceServiceProvider).createInvoice(
            customerId: _selectedCustomer!.id,
            items: itemsPayload,
            initialPayment: {
              'amount': _grandTotal,
              'paymentMethod': 'CASH',
            },
          );

      ref.invalidate(dashboardMetricsProvider);
      ref.invalidate(invoicesListProvider);

      if (shareAfter && result['id'] != null) {
        await ref.read(invoiceServiceProvider).shareWhatsApp(result['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shareAfter ? 'Invoice saved & WhatsApp bill shared!' : 'Invoice saved successfully!'),
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

  void _simulateBarcodeScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanner active. Point camera at product barcode.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersFutureProvider);
    final productsAsync = ref.watch(productsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Invoice',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.brandRed),
            tooltip: 'Scan Barcode',
            onPressed: _simulateBarcodeScanner,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Customer Selection
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Customer',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add, size: 14),
                        label: const Text('+ New Customer', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.brandRed,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                        ),
                        onPressed: () => context.push('/customers'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  customersAsync.when(
                    data: (customers) {
                      // Fallback mock customer list if empty
                      final list = customers.isNotEmpty
                          ? customers
                          : [
                              CustomerModel(id: 'c-01', name: 'Rahul Traders', phone: '9876543210', currentBalance: 12500.0),
                              CustomerModel(id: 'c-02', name: 'Raj Enterprises', phone: '9822334455', currentBalance: 0.0),
                              CustomerModel(id: 'c-03', name: 'City Supermarket', phone: '9422001122', currentBalance: 5200.0),
                            ];

                      return DropdownButtonFormField<CustomerModel>(
                        initialValue: _selectedCustomer,
                        dropdownColor: context.surfaceColor,
                        isExpanded: true,
                        hint: Text('Select from client list...', style: TextStyle(color: context.textMuted, fontSize: 13)),
                        items: list
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${c.name} (${c.phone})', style: TextStyle(fontSize: 13, color: context.textPrimary)),
                                      if (c.currentBalance > 0)
                                        Text(
                                          'Due: ₹${c.currentBalance.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.brandRed, fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCustomer = val),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading customers: $e', style: const TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 2: Products Quick Adder
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Products',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
                      ),
                      Text(
                        'Tap to add',
                        style: TextStyle(fontSize: 11, color: context.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Search product in catalog
                  TextField(
                    onChanged: (val) => setState(() => _productSearchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search catalog products...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  productsAsync.when(
                    data: (products) {
                      // Fallback mock products if empty
                      final catalog = products.isNotEmpty
                          ? products
                          : [
                              ProductModel(id: 'p-01', name: 'Premium Rice 5kg', sellingPrice: 380, purchasePrice: 320, gstRate: 5, currentStock: 48, minStockAlert: 10, unit: 'BAG'),
                              ProductModel(id: 'p-02', name: 'Mustard Oil 1L', sellingPrice: 165, purchasePrice: 135, gstRate: 5, currentStock: 30, minStockAlert: 5, unit: 'BTL'),
                              ProductModel(id: 'p-03', name: 'Tata Tea Gold 500g', sellingPrice: 285, purchasePrice: 240, gstRate: 18, currentStock: 25, minStockAlert: 5, unit: 'PKT'),
                              ProductModel(id: 'p-04', name: 'Wheat Flour 10kg', sellingPrice: 420, purchasePrice: 360, gstRate: 0, currentStock: 20, minStockAlert: 5, unit: 'BAG'),
                            ];

                      final filteredCatalog = catalog.where((p) {
                        return _productSearchQuery.isEmpty || p.name.toLowerCase().contains(_productSearchQuery);
                      }).toList();

                      return SizedBox(
                        height: 105,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredCatalog.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final p = filteredCatalog[index];
                            return InkWell(
                              onTap: () => _addItem(p),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 140,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: context.isDarkMode ? AppColors.darkInputFill : AppColors.lightInputFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: context.borderColor),
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
                                        Text('₹${p.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 13)),
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
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 3: Selected Invoice Items
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cart Items (${_selectedItems.length})',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textSecondary),
                      ),
                      if (_selectedItems.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => _selectedItems.clear()),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.brandRed,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 20),
                          ),
                          child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selectedItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 36, color: context.textMuted),
                          const SizedBox(height: 8),
                          Text('No items added yet', style: TextStyle(fontSize: 13, color: context.textMuted)),
                          const SizedBox(height: 4),
                          Text('Tap products above or scan barcode to add', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final item = _selectedItems[index];
                        final p = item['product'] as ProductModel;
                        final q = item['quantity'] as int;
                        final lineTotal = p.sellingPrice * q;

                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: context.textPrimary, fontSize: 13)),
                                  Text('₹${p.sellingPrice.toStringAsFixed(0)} each • ${p.gstRate}% GST', style: TextStyle(color: context.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                            // Quantity Stepper
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('$q', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimary)),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  icon: const Icon(Icons.add_circle, size: 20, color: AppColors.brandRed),
                                  onPressed: () {
                                    setState(() {
                                      item['quantity'] += 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 68,
                              child: Text(
                                '₹${lineTotal.toStringAsFixed(0)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.textPrimary),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section 4: Calculation Breakdown Block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  _buildCalcRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('0%'),
                            selected: _discountPercent == 0,
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 10),
                            onSelected: (_) => setState(() => _discountPercent = 0.0),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: const Text('5%'),
                            selected: _discountPercent == 5,
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 10),
                            onSelected: (_) => setState(() => _discountPercent = 5.0),
                          ),
                          const SizedBox(width: 4),
                          ChoiceChip(
                            label: const Text('10%'),
                            selected: _discountPercent == 10,
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 10),
                            onSelected: (_) => setState(() => _discountPercent = 10.0),
                          ),
                          const SizedBox(width: 8),
                          Text('-₹${_discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandRed)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildCalcRow('GST (CGST + SGST)', '₹${_gstTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _buildCalcRow('Round Off', '${_roundOff >= 0 ? "+" : ""}₹${_roundOff.toStringAsFixed(2)}'),
                  const Divider(height: 18),
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
                        '₹${_grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 5: Primary & Secondary Submit Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : () => _submitInvoice(shareAfter: false),
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Invoice'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Save & Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.emeraldGreen,
                      side: const BorderSide(color: AppTheme.emeraldGreen),
                    ),
                    onPressed: _submitting ? null : () => _submitInvoice(shareAfter: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textPrimary)),
      ],
    );
  }
}
