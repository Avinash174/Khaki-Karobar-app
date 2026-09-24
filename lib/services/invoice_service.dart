import '../core/network/api_client.dart';
import '../models/invoice_model.dart';

class InvoiceService {
  final ApiClient _client;

  InvoiceService(this._client);

  Future<List<InvoiceModel>> getInvoices({String? search}) async {
    final response = await _client.dio.get(
      '/invoices',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => InvoiceModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createInvoice({
    required String customerId,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? initialPayment,
  }) async {
    final response = await _client.dio.post(
      '/invoices',
      data: {
        'customerId': customerId,
        'items': items,
        if (initialPayment != null) 'initialPayment': initialPayment,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create invoice');
    }
  }

  Future<void> shareWhatsApp(String invoiceId) async {
    await _client.dio.post(
      '/whatsapp/share-invoice',
      data: {'invoiceId': invoiceId},
    );
  }
}
