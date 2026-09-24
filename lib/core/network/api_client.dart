import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient() {
    String endpoint = AppConfig.baseUrl;
    if (!kIsWeb && Platform.isAndroid) {
      endpoint = AppConfig.androidEmulatorBaseUrl;
    }

    dio = Dio(
      BaseOptions(
        baseUrl: endpoint,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'khaki_access_token');
          final businessId = await storage.read(key: 'khaki_active_business_id');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (businessId != null && businessId.isNotEmpty) {
            options.headers['x-business-id'] = businessId;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt token refresh
            final refreshToken = await storage.read(key: 'khaki_refresh_token');
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: endpoint));
                final res = await refreshDio.post(
                  '/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );

                if (res.statusCode == 200 && res.data['success'] == true) {
                  final newAccessToken = res.data['data']['accessToken'];
                  await storage.write(key: 'khaki_access_token', value: newAccessToken);

                  // Retry the original request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final response = await dio.fetch(retryOptions);
                  return handler.resolve(response);
                }
              } catch (_) {
                await storage.deleteAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
