import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../sales/new_sale_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _creating = false;

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text('Add Catalog Product', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(labelText: 'Selling Price (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(labelText: 'Initial Stock Qty'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            onPressed: _creating
                ? null
                : () async {
                    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
                    setState(() => _creating = true);
                    try {
                      final price = double.tryParse(_priceController.text) ?? 0.0;
                      final stock = double.tryParse(_stockController.text) ?? 0.0;
                      await ref.read(productServiceProvider).createProduct(
                            name: _nameController.text.trim(),
                            sellingPrice: price,
                            purchasePrice: price * 0.75,
                            initialStock: stock,
                          );
                      ref.invalidate(productsFutureProvider);
                      _nameController.clear();
                      _priceController.clear();
                      _stockController.clear();
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _creating = false);
                    }
                  },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products & Stock', style: TextStyle(color: context.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: context.textPrimary),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text('No products in catalog', style: TextStyle(color: context.textPrimary, fontSize: 16)));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(productsFutureProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = products[index];

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
                          Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimary)),
                          const SizedBox(height: 2),
                          Text('SKU: ${p.sku ?? "—"} • GST: ${p.gstRate}%', style: TextStyle(color: context.textSecondary, fontSize: 11)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.isLowStock
                                  ? (context.isDarkMode ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade100)
                                  : (context.isDarkMode ? AppTheme.emeraldGreen.withValues(alpha: 0.15) : AppColors.successBg),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.isLowStock ? 'Low Stock' : 'In Stock',
                              style: TextStyle(
                                color: p.isLowStock ? AppColors.error : AppTheme.emeraldGreen,
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
                          Text('₹${p.sellingPrice.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${p.currentStock.toStringAsFixed(0)} ${p.unit}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
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
        error: (e, _) => Center(child: Text('Error loading products: $e', style: const TextStyle(color: AppColors.error))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
