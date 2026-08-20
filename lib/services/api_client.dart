import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  static Future<dynamic> getJson(String path) async {
    final response = await http.get(uri(path));
    return _decode(response);
  }

  static Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  static dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map && decoded['error'] != null
        ? decoded['error'].toString()
        : 'Request failed with status ${response.statusCode}';
    throw Exception(message);
  }
}
