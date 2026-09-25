import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'auth_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductService(client);
});

final productsFutureProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getProducts();
});

final lowStockProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getLowStockAlerts();
});

final inventorySummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getInventorySummary();
});
