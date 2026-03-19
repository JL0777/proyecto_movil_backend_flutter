import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session/session_manager.dart';
import '../core/config/app_config.dart';

class PedidoService {
  static const String baseUrl = '${AppConfig.baseUrl}/pedidos';

  Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {"success": true, "pedido": body['pedido']};
    }

    return {"success": false, "error": body['error'] ?? "Error desconocido"};
  }

  Future<List<dynamic>> getMisPedidos() async {
    final response = await http.get(
      Uri.parse("$baseUrl/mis-pedidos"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando pedidos");
  }

  Future<List<dynamic>> getAll() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando pedidos");
  }

  Future<List<dynamic>> getPedidosCocina() async {
    final response = await http.get(
      Uri.parse("$baseUrl/cocina"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando pedidos de cocina");
  }

  Future<Map<String, dynamic>> updateEstado(int id, String estado) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id/estado"),
      headers: await _headers(),
      body: jsonEncode({"estado": estado}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true};
    }

    return {"success": false, "error": body['error'] ?? "Error desconocido"};
  }

  Future<Map<String, dynamic>> updateEstadoCocina(
      int id, String estado) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id/estado-cocina"),
      headers: await _headers(),
      body: jsonEncode({"estado": estado}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true};
    }

    return {"success": false, "error": body['error'] ?? "Error desconocido"};
  }
}