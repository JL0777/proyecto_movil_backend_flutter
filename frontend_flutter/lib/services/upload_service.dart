import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/session/session_manager.dart';
import '../core/config/app_config.dart';

class UploadService {
  static const String baseUrl = '${AppConfig.baseUrl}/upload';

  Future<String?> subirImagen(File imagen) async {
    try {
      final token = await SessionManager.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          imagen.path,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['url'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> eliminarImagen(String url) async {
  try {
    // Extraer el filename de la URL
    final filename = url.split('/uploads/').last;

    if (filename.isEmpty) return true;

    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/upload/$filename'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}