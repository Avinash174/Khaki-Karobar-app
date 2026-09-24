import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../sales/new_sale_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late double _currentStock;

  @override
  void initState() {
    super.initState();
    _currentStock = widget.product.currentStock;
  }

  void _showAdjustStockDialog() {
    final qtyController = TextEditingController();
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            'Adjust Stock',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('+ Add Stock')),
                      selected: isAddition,
                      selectedColor: AppTheme.emeraldGreen,
                      onSelected: (_) => setDialogState(() => isAddition = true),
                      labelStyle: TextStyle(
                        color: isAddition ? Colors.white : context.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('- Reduce Stock')),
                      selected: !isAddition,
                      selectedColor: AppTheme.primaryRed,
                      onSelected: (_) => setDialogState(() => isAddition = false),
                      labelStyle: TextStyle(
                        color: !isAddition ? Colors.white : context.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Quantity (${widget.product.unit})',
                  hintText: 'e.g. 10',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(qtyController.text.trim()) ?? 0;
                if (qty > 0) {
                  setState(() {
                    if (isAddition) {
                      _currentStock += qty;
                    } else {
                      _currentStock = (_currentStock - qty).clamp(0, double.infinity);
                    }
                  });
                  ref.invalidate(productsFutureProvider);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock adjusted successfully to $_currentStock ${widget.product.unit}'),
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                  );
                }
              },
              child: const Text('Update Stock'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isLowStock = _currentStock <= p.minStockAlert;
    final isOutOfStock = _currentStock <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.textPrimary, size: 20),
            tooltip: 'Edit Product',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product edit mode ready.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.brandRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2, color: AppColors.brandRed, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${p.sku ?? "SKU-${p.id.substring(0, p.id.length > 6 ? 6 : p.id.length)}"}',
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? AppTheme.primaryRed.withValues(alpha: 0.15)
                                : (isLowStock ? AppTheme.amberGold.withValues(alpha: 0.15) : AppTheme.emeraldGreen.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOutOfStock ? 'Out of Stock' : (isLowStock ? 'Low Stock Alert' : 'In Stock'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOutOfStock ? AppTheme.primaryRed : (isLowStock ? AppTheme.amberGold : AppTheme.emeraldGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pricing & Stock Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Selling Price',
                    value: '₹${p.sellingPrice.toStringAsFixed(0)}',
                    color: AppTheme.emeraldGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Purchase Price',
                    value: '₹${p.purchasePrice.toStringAsFixed(0)}',
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Current Stock',
                    value: '$_currentStock ${p.unit}',
                    color: isLowStock ? AppTheme.primaryRed : context.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Min. Threshold',
                    value: '${p.minStockAlert.toStringAsFixed(0)} ${p.unit}',
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Tax Rate (GST)', '${p.gstRate}%'),
                  const Divider(height: 16),
                  _buildDetailRow('Barcode', p.barcode ?? '890123456789'),
                  const Divider(height: 16),
                  _buildDetailRow('Unit of Measure', p.unit),
                  const Divider(height: 16),
                  _buildDetailRow('Primary Supplier', 'Hindustan Wholesale Corp'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Inventory History Section
            Text(
              'Stock Movement History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildHistoryItem('Sale - INV-1024', '-4 ${p.unit}', 'Today, 11:30 AM', Colors.redAccent),
            _buildHistoryItem('Stock Added', '+50 ${p.unit}', '22 Sep 2026', AppTheme.emeraldGreen),
            _buildHistoryItem('Sale - INV-1019', '-10 ${p.unit}', '20 Sep 2026', Colors.redAccent),
            const SizedBox(height: 24),

            // Bottom Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sync_alt, size: 16),
                    label: const Text('Adjust Stock'),
                    onPressed: _showAdjustStockDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('New Invoice'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: context.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
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

  Widget _buildHistoryItem(String title, String qty, String date, Color qtyColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary)),
              Text(date, style: TextStyle(fontSize: 10, color: context.textMuted)),
            ],
          ),
          Text(
            qty,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: qtyColor),
          ),
        ],
      ),
    );
  }
}
