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

  Future<Map<String, dynamic>> adjustStock({
    required String productId,
    required String adjustmentType, // 'ADD' | 'SUBTRACT' | 'SET'
    required double quantity,
    String? notes,
  }) async {
    final response = await _client.dio.post(
      '/inventory/adjust',
      data: {
        'productId': productId,
        'adjustmentType': adjustmentType,
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to adjust stock');
    }
  }

  Future<Map<String, dynamic>> getInventorySummary() async {
    final response = await _client.dio.get('/inventory/summary');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    return {};
  }

  Future<List<ProductModel>> getLowStockAlerts() async {
    final response = await _client.dio.get('/inventory/low-stock');
    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }
}

