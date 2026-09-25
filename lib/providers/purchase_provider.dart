import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';
import 'auth_provider.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PurchaseService(client);
});

final purchasesFutureProvider = FutureProvider.autoDispose<List<PurchaseModel>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getPurchases();
});
