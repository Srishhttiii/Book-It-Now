import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class ApiClient {
  static Uri uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

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
