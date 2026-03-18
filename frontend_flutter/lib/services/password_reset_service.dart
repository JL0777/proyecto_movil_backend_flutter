import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class PasswordResetService {
  static const String baseUrl = '${AppConfig.baseUrl}/password-reset';

  // Solicitar código
  Future<Map<String, dynamic>> solicitarCodigo(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'error': data['error'] ?? 'Error desconocido'};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Verificar código
  Future<Map<String, dynamic>> verificarCodigo(String email, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verificar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'codigo': codigo}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'error': data['error'] ?? 'Error desconocido'};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Cambiar contraseña
  Future<Map<String, dynamic>> cambiarPassword(
      String email, String codigo, String nuevaPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cambiar-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'codigo': codigo,
          'nuevaPassword': nuevaPassword
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'error': data['error'] ?? 'Error desconocido'};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}