import 'dart:convert';
import 'package:crops4you/config/api_config.dart';
import 'package:crops4you/main.dart';
import 'package:crops4you/models/actividad.dart';
import 'package:http/http.dart' as http;

class ActividadService {
  final String _baseUrl = '${ApiConfig.backendBaseUrl}/actividades';

  Map<String, String> _headers() {
    final session = supabase.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Actividad>> getByCultivo(int cultivoId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?cultivo_id=$cultivoId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Actividad.fromJson(e)).toList();
    }
    throw Exception(_mensajeError(response));
  }

  Future<void> create(Actividad actividad) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final body = actividad.toJson();
    body['user_id'] = user.id;
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
  }

  Future<void> completar(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
      body: jsonEncode({'completado': true}),
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  Future<void> desmarcar(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
      body: jsonEncode({'completado': false}),
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['mensaje'] ?? 'Error: ${response.statusCode}';
    } catch (_) {
      return 'Error: ${response.statusCode}';
    }
  }
}
