import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session/session_manager.dart';
import '../../core/config/app_config.dart';


class AddressService {

  static const String baseUrl = '${AppConfig.baseUrl}/auth';

  Future<Map<String,String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future<List<dynamic>> getAddresses() async {

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }

    throw Exception("Error cargando direcciones");
  }

  Future<bool> createAddress(Map data) async {

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateAddress(int id, Map data) async {

    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteAddress(int id) async {

    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: await _headers(),
    );

    return response.statusCode == 200;
  }

}