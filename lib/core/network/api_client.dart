import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Completer<String?>? _refreshCompleter;

  Future<String?> _performTokenRefresh(String endpoint) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await storage.read(key: 'khaki_refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: endpoint,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final res = await refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        final newAccessToken = res.data['data']['accessToken'] as String?;
        if (newAccessToken != null) {
          await storage.write(key: 'khaki_access_token', value: newAccessToken);
          completer.complete(newAccessToken);
          return newAccessToken;
        }
      }
      await storage.deleteAll();
      completer.complete(null);
      return null;
    } catch (_) {
      await storage.deleteAll();
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

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
          // Prevent loop if the refresh request itself triggered 401
          if (error.requestOptions.path.contains('/auth/refresh')) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            final newAccessToken = await _performTokenRefresh(endpoint);
            if (newAccessToken != null) {
              try {
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final response = await dio.fetch(retryOptions);
                return handler.resolve(response);
              } catch (retryError) {
                if (retryError is DioException) {
                  return handler.next(retryError);
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
