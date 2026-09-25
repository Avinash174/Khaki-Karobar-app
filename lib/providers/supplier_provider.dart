import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';
import 'auth_provider.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  final client = ref.watch(apiClientProvider);
  return SupplierService(client);
});

final suppliersFutureProvider = FutureProvider.autoDispose<List<SupplierModel>>((ref) async {
  final service = ref.watch(supplierServiceProvider);
  return service.getSuppliers();
});
