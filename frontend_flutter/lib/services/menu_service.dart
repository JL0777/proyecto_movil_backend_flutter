import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session/session_manager.dart';
import '../core/config/app_config.dart';

class MenuService {
  static const String baseUrl = '${AppConfig.baseUrl}/menus';

  Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getByCategoria(int categoriaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/categoria/$categoriaId"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando menús");
  }

  Future<Map<String, dynamic>> getOne(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando menú");
  }

  Future<List<dynamic>> getAll() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando menús");
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

  Future<List<dynamic>> buscar(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/buscar?q=${Uri.encodeComponent(query)}"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error en la búsqueda");
  }

  Future<List<dynamic>> getByCategoriaPublico(int categoriaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/publico/categoria/$categoriaId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando menús");
  }

  Future<bool> updateNutricional(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/nutricional/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMenusBalanceados({String? objetivo}) async {
    final uri = objetivo != null
        ? Uri.parse("$baseUrl/balanceados?objetivo=$objetivo")
        : Uri.parse("$baseUrl/balanceados");

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando menús balanceados");
  }

  Future<Map<String, dynamic>> getPerfilNutricionalCliente() async {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}/users/perfil-nutricional"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando perfil nutricional");
  }

  Future<bool> toggleDisponible(int id) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/$id/toggle"),
      headers: await _headers(),
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> buscarPublico(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/publico/buscar?q=${Uri.encodeComponent(query)}"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error en la búsqueda");
  }
}
