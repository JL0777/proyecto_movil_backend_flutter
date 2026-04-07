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
      "Authorization": "Bearer $token",
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

  Future<Map<String, dynamic>> getHistorial({
    String? fechaInicio,
    String? fechaFin,
    String? estado,
    String? tipo,
    String? metodoPago,
  }) async {
    final params = <String, String>{};
    if (fechaInicio != null) params['fechaInicio'] = fechaInicio;
    if (fechaFin != null) params['fechaFin'] = fechaFin;
    if (estado != null) params['estado'] = estado;
    if (tipo != null) params['tipo'] = tipo;
    if (metodoPago != null) params['metodoPago'] = metodoPago;

    final uri = Uri.parse(
      "$baseUrl/historial",
    ).replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando historial");
  }
}
