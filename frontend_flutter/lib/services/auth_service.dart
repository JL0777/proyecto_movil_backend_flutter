import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/session/session_manager.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.11:3000/api/auth';

  // ======================
  // REGISTER
  // ======================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? telefono,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'telefono': telefono,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'error': data['error'] ?? 'Error desconocido',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // ======================
  // LOGIN
  // ======================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        // 🔥 Guardamos sesión automáticamente aquí
        await SessionManager.saveSession(
          token: data['token'],
          user: data['user'],
        );

        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'error': data['error'] ?? 'Error desconocido',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // ======================
  // LOGOUT
  // ======================
  Future<void> logout() async {
    await SessionManager.clearSession();
  }

  // ======================
  // GET TOKEN
  // ======================
  Future<String?> getToken() async {
    return await SessionManager.getToken();
  }

  // ======================
  // CHECK SESSION
  // ======================
  Future<bool> isLoggedIn() async {
    return await SessionManager.isLoggedIn();
  }
}