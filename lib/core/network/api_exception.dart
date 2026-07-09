import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors = const {},
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, List<String>> errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    final data = body is Map
        ? Map<String, dynamic>.from(body)
        : const <String, dynamic>{};
    final rawErrors = data['errors'];
    final errors = <String, List<String>>{};

    if (rawErrors is Map) {
      for (final entry in rawErrors.entries) {
        final value = entry.value;
        errors['${entry.key}'] =
            value is List ? value.map((item) => '$item').toList() : ['$value'];
      }
    }

    return ApiException(
      statusCode: status,
      code: data['code']?.toString(),
      errors: errors,
      message: data['message']?.toString() ?? _fallbackMessage(error, status),
    );
  }

  static String _fallbackMessage(DioException error, int? status) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Le serveur met trop de temps à répondre.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Connexion au serveur impossible.';
    }
    if (status != null && status >= 500) {
      return 'Le serveur rencontre un problème.';
    }
    return switch (status) {
      401 => 'Votre session a expiré.',
      403 => 'Cette action n’est pas autorisée.',
      422 => 'Certaines informations sont invalides.',
      429 => 'Trop de tentatives. Réessayez plus tard.',
      _ => 'Une erreur réseau est survenue.',
    };
  }

  @override
  String toString() => message;
}
