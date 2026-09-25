import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await _client.dio.post(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = UserModel.fromJson(data['user']);
      final activeBusiness = data['activeBusiness'] != null
          ? BusinessModel.fromJson(data['activeBusiness'])
          : null;

      await _client.storage.write(key: 'khaki_access_token', value: accessToken);
      await _client.storage.write(key: 'khaki_refresh_token', value: refreshToken);
      if (activeBusiness != null) {
        await _client.storage.write(key: 'khaki_active_business_id', value: activeBusiness.id);
      }

      return {
        'user': user,
        'business': activeBusiness,
      };
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, {String? name}) async {
    final response = await _client.dio.post(
      '/auth/otp/verify',
      data: {'phone': phone, 'otp': otp, if (name != null) 'name': name},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = UserModel.fromJson(data['user']);
      final activeBusiness = data['activeBusiness'] != null
          ? BusinessModel.fromJson(data['activeBusiness'])
          : null;

      await _client.storage.write(key: 'khaki_access_token', value: accessToken);
      await _client.storage.write(key: 'khaki_refresh_token', value: refreshToken);
      if (activeBusiness != null) {
        await _client.storage.write(key: 'khaki_active_business_id', value: activeBusiness.id);
      }

      return {
        'user': user,
        'business': activeBusiness,
      };
    } else {
      throw Exception(response.data['message'] ?? 'OTP verification failed');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    String? businessName,
  }) async {
    final response = await _client.dio.post(
      '/auth/register',
      data: {
        'name': name,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        'password': password,
        if (businessName != null && businessName.isNotEmpty)
          'businessName': businessName,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = UserModel.fromJson(data['user']);
      final activeBusiness = data['business'] != null
          ? BusinessModel.fromJson(data['business'])
          : null;

      if (accessToken != null) {
        await _client.storage.write(key: 'khaki_access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await _client.storage.write(key: 'khaki_refresh_token', value: refreshToken);
      }
      if (activeBusiness != null) {
        await _client.storage.write(key: 'khaki_active_business_id', value: activeBusiness.id);
      }

      return {
        'user': user,
        'business': activeBusiness,
      };
    } else {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> requestOtp(String phone, {String purpose = 'LOGIN'}) async {
    final response = await _client.dio.post(
      '/auth/otp/request',
      data: {'phone': phone, 'purpose': purpose},
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> logout() async {
    await _client.storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _client.storage.read(key: 'khaki_access_token');
    return token != null && token.isNotEmpty;
  }
}
