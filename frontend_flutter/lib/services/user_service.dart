import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/session/session_manager.dart';

class UserService {
  static const String baseUrl = "${AppConfig.baseUrl}/users";

  Future<String?> _getToken() async {
    return await SessionManager.getToken();
  }

  Future<Map<String, dynamic>> updateName(String nombre) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/name"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"nombre": nombre}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await SessionManager.saveSession(token: token!, user: data['user']);

      return {"success": true, "user": data['user']};
    }

    return {"success": false, "error": data["error"]};
  }

  // ======================
  // SOLICITAR CÓDIGO PARA CAMBIO DE EMAIL
  // ======================
  Future<Map<String, dynamic>> solicitarCodigoEmail(String newEmail) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/email/solicitar-codigo"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"newEmail": newEmail}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"]};
    }

    return {"success": false, "error": data["error"]};
  }

  // ======================
  // VERIFICAR CÓDIGO Y ACTUALIZAR EMAIL
  // ======================
  Future<Map<String, dynamic>> updateEmail(
    String currentEmail,
    String newEmail,
    String codigo,
  ) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/email"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "currentEmail": currentEmail,
        "newEmail": newEmail,
        "codigo": codigo,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await SessionManager.saveSession(token: token!, user: data['user']);

      return {"success": true, "user": data['user']};
    }

    return {"success": false, "error": data["error"]};
  }

  Future<Map<String, dynamic>> updatePhone(
    String currentPhone,
    String newPhone,
  ) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/phone"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"currentPhone": currentPhone, "newPhone": newPhone}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await SessionManager.saveSession(token: token!, user: data['user']);

      return {"success": true, "user": data['user']};
    }

    return {"success": false, "error": data["error"]};
  }

  Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"]};
    }

    return {"success": false, "error": data["error"]};
  }


Future<Map<String, dynamic>> updateFotoPerfil(String fotoPerfil) async {
  final token = await _getToken();

  final response = await http.put(
    Uri.parse("$baseUrl/foto-perfil"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({"fotoPerfil": fotoPerfil}),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    await SessionManager.saveSession(token: token!, user: data['user']);
    return {"success": true, "user": data['user']};
  }

  return {"success": false, "error": data["error"]};
}
}
