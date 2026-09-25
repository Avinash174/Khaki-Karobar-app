import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentService(client);
});

final paymentsFutureProvider = FutureProvider.autoDispose<List<PaymentModel>>((ref) async {
  final service = ref.watch(paymentServiceProvider);
  return service.getPayments();
});
