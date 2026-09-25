import '../core/network/api_client.dart';
import '../models/supplier_model.dart';

class SupplierService {
  final ApiClient _client;

  SupplierService(this._client);

  Future<List<SupplierModel>> getSuppliers({String? search}) async {
    final response = await _client.dio.get(
      '/suppliers',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => SupplierModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<SupplierModel> createSupplier({
    required String name,
    required String phone,
    String? email,
    String? contactPerson,
    String? gstin,
    String? city,
    String? address,
    double openingBalance = 0,
  }) async {
    final response = await _client.dio.post(
      '/suppliers',
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'contactPerson': contactPerson,
        'gstin': gstin,
        'city': city,
        'address': address,
        'openingBalance': openingBalance,
      },
    );

    if (response.data['success'] == true) {
      return SupplierModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create supplier');
    }
  }

  Future<SupplierModel> getSupplierById(String id) async {
    final response = await _client.dio.get('/suppliers/$id');
    if (response.data['success'] == true) {
      return SupplierModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch supplier');
    }
  }

  Future<List<dynamic>> getSupplierLedger(String id) async {
    final response = await _client.dio.get('/suppliers/$id/ledger');
    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) return data;
      if (data is Map && data['items'] is List) return data['items'];
      return [];
    }
    return [];
  }
}
