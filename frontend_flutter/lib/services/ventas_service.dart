import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session/session_manager.dart';
import '../core/config/app_config.dart';

class VentasService {
  static const String baseUrl = '${AppConfig.baseUrl}/ventas';

  Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future<Map<String, dynamic>> getReporte() async {
    final response = await http.get(
      Uri.parse("$baseUrl/reporte"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando reporte");
  }
}