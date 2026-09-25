import '../core/network/api_client.dart';
import '../models/payment_model.dart';

class PaymentService {
  final ApiClient _client;

  PaymentService(this._client);

  Future<List<PaymentModel>> getPayments({String? type, String? partyType}) async {
    final response = await _client.dio.get(
      '/payments',
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
        if (partyType != null && partyType.isNotEmpty) 'partyType': partyType,
      },
    );

    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => PaymentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<PaymentModel> createPayment({
    required String partyType, // 'CUSTOMER' | 'SUPPLIER'
    String? customerId,
    String? supplierId,
    String? invoiceId,
    String? purchaseId,
    required double amount,
    String paymentMethod = 'CASH',
    String? referenceNumber,
    String? notes,
  }) async {
    final response = await _client.dio.post(
      '/payments',
      data: {
        'partyType': partyType,
        if (customerId != null) 'customerId': customerId,
        if (supplierId != null) 'supplierId': supplierId,
        if (invoiceId != null) 'invoiceId': invoiceId,
        if (purchaseId != null) 'purchaseId': purchaseId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        if (referenceNumber != null && referenceNumber.isNotEmpty) 'referenceNumber': referenceNumber,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    if (response.data['success'] == true) {
      return PaymentModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to record payment');
    }
  }
}
