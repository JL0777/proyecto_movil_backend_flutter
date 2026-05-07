import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/session/session_manager.dart';

class UsdaService {
  Future<Map<String, dynamic>?> buscarNutricional(String nombre) async {
    try {
      final token = await SessionManager.getToken();

      final uri = Uri.parse(
       '${AppConfig.baseUrl}/ingredientes/nutricional/buscar',
      ).replace(queryParameters: {'nombre': nombre});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['datos'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}