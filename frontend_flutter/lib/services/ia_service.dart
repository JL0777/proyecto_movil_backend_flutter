import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/session/session_manager.dart';

class IaService {
  Future<Map<String, dynamic>> generarPlanComidas() async {
    try {
      final token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/ia/plan-comidas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'plan': data['plan']};
      }

      return {
        'success': false,
        'error': data['error'] ?? 'Error al generar el plan',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> completarMenuConIA(String nombre) async {
    try {
      final token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/ia/completar-menu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nombre': nombre}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'datos': data['datos']};
      }

      return {
        'success': false,
        'error': data['error'] ?? 'Error al completar el menú',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  /// Analiza una foto de comida usando Gemini Vision vía backend.
  /// Devuelve macros, calorías y nombre del plato detectado.
  Future<Map<String, dynamic>> analizarFotoComida(File imagen) async {
    try {
      final token = await SessionManager.getToken();

      // Convertir imagen a base64
      final bytes = await imagen.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Detectar tipo MIME según extensión
      final ext = imagen.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/ia/analizar-foto'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'imagen': base64Image,
          'mimeType': mimeType,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'resultado': data['resultado']};
      }

      return {
        'success': false,
        'error': data['error'] ?? 'No se pudo analizar la imagen',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }
}