import '../core/network/api_client.dart';
import '../models/purchase_model.dart';

class PurchaseService {
  final ApiClient _client;

  PurchaseService(this._client);

  Future<List<PurchaseModel>> getPurchases({String? search}) async {
    final response = await _client.dio.get(
      '/purchases',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => PurchaseModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<PurchaseModel> createPurchase({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    double paidAmount = 0.0,
    String? notes,
  }) async {
    final response = await _client.dio.post(
      '/purchases',
      data: {
        'supplierId': supplierId,
        'items': items,
        'paidAmount': paidAmount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    if (response.data['success'] == true) {
      return PurchaseModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create purchase');
    }
  }

  Future<Map<String, dynamic>> getPurchaseById(String id) async {
    final response = await _client.dio.get('/purchases/$id');
    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch purchase');
    }
  }
}
