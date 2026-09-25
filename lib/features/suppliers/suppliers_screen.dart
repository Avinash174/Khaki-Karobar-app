import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/supplier_provider.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final payableCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                    'Add New Supplier',
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
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supplier / Company Name *',
                  hintText: 'e.g. Apex Commodities',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '9876543210',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(labelText: 'City', hintText: 'Pune'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: payableCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Opening Payable (₹)', hintText: '0'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isCreating
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        if (name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill Name and Phone')),
                          );
                          return;
                        }

                        setModalState(() => _isCreating = true);
                        try {
                          await ref.read(supplierServiceProvider).createSupplier(
                                name: name,
                                phone: phone,
                                city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : null,
                                openingBalance: double.tryParse(payableCtrl.text.trim()) ?? 0.0,
                              );
                          ref.invalidate(suppliersFutureProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Supplier added successfully!'),
                                backgroundColor: AppTheme.emeraldGreen,
                              ),
                            );
                          }
                        } catch (e) {
                          setModalState(() => _isCreating = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString().replaceAll('Exception: ', '')),
                                backgroundColor: AppTheme.primaryRed,
                              ),
                            );
                          }
                        }
                      },
                child: _isCreating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Supplier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suppliers & Vendors',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.brandRed),
            tooltip: 'Add Supplier',
            onPressed: _showAddSupplierDialog,
          ),
        ],
      ),
      body: suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandRed)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load suppliers',
                style: TextStyle(color: context.textSecondary),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(suppliersFutureProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (suppliers) {
          final filtered = suppliers.where((s) {
            final q = _searchQuery.toLowerCase();
            return _searchQuery.isEmpty ||
                s.name.toLowerCase().contains(q) ||
                s.phone.contains(q) ||
                (s.city?.toLowerCase().contains(q) ?? false);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search suppliers by name or phone...',
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
                child: RefreshIndicator(
                  onRefresh: () async => ref.refresh(suppliersFutureProvider),
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Text(
                                _searchQuery.isEmpty ? 'No suppliers registered yet' : 'No suppliers match your search',
                                style: TextStyle(color: context.textSecondary),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final payable = s.currentBalance;
                            final hasPayable = payable > 0;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.borderColor),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.purple.withValues(alpha: 0.12),
                                    child: Text(
                                      s.name.isNotEmpty ? s.name.substring(0, 1).toUpperCase() : 'S',
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: context.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${s.phone}${s.city != null && s.city!.isNotEmpty ? ' • ${s.city}' : ''}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        hasPayable ? 'Payable' : 'Settled',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: hasPayable ? Colors.purpleAccent : AppTheme.emeraldGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${payable.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: hasPayable ? Colors.purpleAccent : AppTheme.emeraldGreen,
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
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddSupplierDialog,
      ),
    );
  }
}
