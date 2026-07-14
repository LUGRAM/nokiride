import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/app_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppStorage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await AppStorage.clearAuth();
          }
          handler.next(error);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }
  }

  static final ApiClient instance = ApiClient._();
  final Dio _dio;

  static String get _baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) return configuredUrl;

    const apiHost = String.fromEnvironment(
      'API_HOST',
      defaultValue: '192.168.1.81',
    );
    const apiPort = String.fromEnvironment('API_PORT', defaultValue: '9000');
    const apiScheme =
        String.fromEnvironment('API_SCHEME', defaultValue: 'http');

    if (kIsWeb) return '$apiScheme://$apiHost:$apiPort/api/v1';
    if (Platform.isAndroid) return '$apiScheme://$apiHost:$apiPort/api/v1';
    return '$apiScheme://$apiHost:$apiPort/api/v1';
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request('GET', endpoint, queryParameters: queryParameters);

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) =>
      _request('POST', endpoint, data: data);

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? data,
  }) =>
      _request('PATCH', endpoint, data: data);

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      final body = response.data;
      if (body == null) return <String, dynamic>{};
      if (body is Map<String, dynamic>) return body;
      if (body is Map) return Map<String, dynamic>.from(body);
      throw const ApiException(message: 'Réponse serveur invalide.');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
