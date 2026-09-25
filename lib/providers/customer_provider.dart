import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'auth_provider.dart';

final customerServiceProvider = Provider<CustomerService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomerService(client);
});

final customersFutureProvider = FutureProvider.autoDispose<List<CustomerModel>>((ref) async {
  final service = ref.watch(customerServiceProvider);
  return service.getCustomers();
});

final customerLedgerProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, id) async {
  final service = ref.watch(customerServiceProvider);
  return service.getCustomerLedger(id);
});
