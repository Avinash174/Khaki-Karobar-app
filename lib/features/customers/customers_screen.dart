import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../sales/new_sale_screen.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  bool _creating = false;

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text('Add New Customer', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cityController,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(labelText: 'City'),
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
                    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
                    setState(() => _creating = true);
                    try {
                      await ref.read(customerServiceProvider).createCustomer(
                            name: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                            city: _cityController.text.trim(),
                          );
                      ref.invalidate(customersFutureProvider);
                      _nameController.clear();
                      _phoneController.clear();
                      _cityController.clear();
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
            child: const Text('Save Customer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Customers & CRM', style: TextStyle(color: context.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: context.textPrimary),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return Center(child: Text('No customers found', style: TextStyle(color: context.textPrimary, fontSize: 16)));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(customersFutureProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final c = customers[index];
                final hasDue = c.currentBalance > 0;

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
                          Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimary)),
                          const SizedBox(height: 2),
                          Text('${c.phone} • ${c.city ?? "Pune"}', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                          if (c.gstin != null)
                            Text('GSTIN: ${c.gstin}', style: TextStyle(fontSize: 10, color: context.textMuted)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Balance', style: TextStyle(fontSize: 10, color: context.textSecondary)),
                          Text(
                            '₹${c.currentBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: hasDue ? AppTheme.amberGold : AppTheme.emeraldGreen,
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
        error: (e, _) => Center(child: Text('Error loading customers: $e', style: const TextStyle(color: AppColors.error))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
