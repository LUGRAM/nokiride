import 'package:flutter_test/flutter_test.dart';
import 'package:nokiride/core/network/api_exception.dart';

void main() {
  test('classifies authentication and validation errors', () {
    const unauthorized = ApiException(
      message: 'Session expirée',
      statusCode: 401,
    );
    const validation = ApiException(
      message: 'Données invalides',
      statusCode: 422,
      errors: {
        'phone': ['Format invalide'],
      },
    );

    expect(unauthorized.isUnauthorized, isTrue);
    expect(validation.isValidationError, isTrue);
    expect(validation.errors['phone'], contains('Format invalide'));
  });

  test('classifies forbidden and server errors', () {
    const forbidden = ApiException(message: 'Interdit', statusCode: 403);
    const server = ApiException(message: 'Serveur', statusCode: 500);

    expect(forbidden.isForbidden, isTrue);
    expect(server.isServerError, isTrue);
  });
}
