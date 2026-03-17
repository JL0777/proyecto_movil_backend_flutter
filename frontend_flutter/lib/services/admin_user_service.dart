import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session/session_manager.dart';
import '../../core/config/app_config.dart';

class AdminUserService {
  static const String baseUrl = '${AppConfig.baseUrl}/users';

  Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando usuarios");
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando usuario");
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "user": body['user']};
    }

    return {"success": false, "error": body['error'] ?? "Error desconocido"};
  }

  Future<Map<String, dynamic>> updatePassword(int id, String newPassword) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id/password"),
      headers: await _headers(),
      body: jsonEncode({"newPassword": newPassword}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true};
    }

    return {"success": false, "error": body['error'] ?? "Error desconocido"};
  }
}