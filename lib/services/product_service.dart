import '../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<List<ProductModel>> getProducts({String? search, bool? lowStock}) async {
    final response = await _client.dio.get(
      '/products',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (lowStock == true) 'lowStock': 'true',
      },
    );

    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<ProductModel> createProduct({
    required String name,
    required double sellingPrice,
    required double purchasePrice,
    required double initialStock,
    String unit = 'PCS',
    double gstRate = 18,
    String? sku,
  }) async {
    final response = await _client.dio.post(
      '/products',
      data: {
        'name': name,
        'sellingPrice': sellingPrice,
        'purchasePrice': purchasePrice,
        'initialStock': initialStock,
        'unit': unit,
        'gstRate': gstRate,
        'sku': sku,
      },
    );

    if (response.data['success'] == true) {
      return ProductModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create product');
    }
  }
}
