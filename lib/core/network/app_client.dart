import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppClient extends GetxService {
  final String baseUrl = "https://votre-api-laravel.com/api"; // À remplacer

  Future<dynamic> postData(String uri, Map<String, dynamic> body, {String? token}) async {
    try {
      var response = await http.post(
        Uri.parse(baseUrl + uri),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Erreur de connexion'};
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur serveur: ${response.statusCode}");
    }
  }
}