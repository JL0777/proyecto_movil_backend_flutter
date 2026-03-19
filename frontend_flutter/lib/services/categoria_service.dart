import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session/session_manager.dart';
import '../core/config/app_config.dart';

class CategoriaService {
  static const String baseUrl = '${AppConfig.baseUrl}/categorias';

  Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getByTipo(String tipo) async {
    final response = await http.get(
      Uri.parse("$baseUrl/tipo/$tipo"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando categorías");
  }

  Future<List<dynamic>> getAll() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando categorías");
  }

  Future<bool> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<bool> delete(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getByTipoPublico(String tipo) async {
    final response = await http.get(Uri.parse("$baseUrl/publico/tipo/$tipo"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando categorías");
  }

  Future<List<dynamic>> getAllPublico() async {
    final response = await http.get(Uri.parse("$baseUrl/publico"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando categorías");
  }
}
