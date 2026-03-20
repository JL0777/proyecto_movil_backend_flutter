import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/session/session_manager.dart';

class AuthService {
  static const String baseUrl = '${AppConfig.baseUrl}/auth';

  // ======================
  // REGISTER — solo envía código
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

      if (response.statusCode == 200) {
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
  // VERIFICAR CÓDIGO Y CREAR CUENTA
  // ======================
  Future<Map<String, dynamic>> verificarRegistro({
    required String email,
    required String codigo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verificar-registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'codigo': codigo,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
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
  // REENVIAR CÓDIGO DE REGISTRO
  // ======================
  Future<Map<String, dynamic>> reenviarCodigoRegistro({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reenviar-codigo-registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
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