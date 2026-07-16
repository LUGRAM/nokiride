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
    _dio.interceptors.add(_SelectiveRetryInterceptor(_dio));
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
      _request(
        'GET',
        endpoint,
        queryParameters: queryParameters,
        retryable: true,
      );

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    bool retryable = false,
  }) =>
      _request('POST', endpoint, data: data, retryable: retryable);

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
    bool retryable = false,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          extra: {'retryable': retryable, 'retry_count': 0},
        ),
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

class _SelectiveRetryInterceptor extends Interceptor {
  _SelectiveRetryInterceptor(this._dio);

  final Dio _dio;
  static const _delays = <Duration>[
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    final retryable = options.extra['retryable'] == true;
    final retryCount = options.extra['retry_count'] as int? ?? 0;
    if (!retryable || retryCount >= _delays.length || !_shouldRetry(error)) {
      handler.next(error);
      return;
    }

    await Future<void>.delayed(_delays[retryCount]);
    options.extra['retry_count'] = retryCount + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (nextError) {
      handler.next(nextError);
    }
  }

  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }
    return const <int>{429, 502, 503, 504}.contains(error.response?.statusCode);
  }
}
