import '../core/network/api_client.dart';
import '../models/customer_model.dart';

class CustomerService {
  final ApiClient _client;

  CustomerService(this._client);

  Future<List<CustomerModel>> getCustomers({String? search}) async {
    final response = await _client.dio.get(
      '/customers',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (response.data['success'] == true) {
      final items = response.data['data']['items'] as List;
      return items.map((e) => CustomerModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<CustomerModel> createCustomer({
    required String name,
    required String phone,
    String? email,
    String? city,
    double openingBalance = 0,
  }) async {
    final response = await _client.dio.post(
      '/customers',
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'city': city,
        'openingBalance': openingBalance,
      },
    );

    if (response.data['success'] == true) {
      return CustomerModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create customer');
    }
  }
}
