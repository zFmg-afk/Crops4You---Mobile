import 'dart:convert';
import 'package:crops4you/config/api_config.dart';
import 'package:crops4you/main.dart';
import 'package:crops4you/models/recordatorio.dart';
import 'package:http/http.dart' as http;

class RecordatorioService {
  final String _baseUrl = '${ApiConfig.backendBaseUrl}/recordatorios';

  Map<String, String> _headers() {
    final session = supabase.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  String _mensajeError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['mensaje'] != null) return body['mensaje'];
    } catch (_) {}
    return 'Error del servidor: ${response.statusCode}';
  }

  Future<List<Recordatorio>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl), headers: _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Recordatorio.fromJson(e)).toList();
    }
    throw Exception(_mensajeError(response));
  }

  Future<List<Recordatorio>> getPendientes() async {
    final todos = await getAll();
    return todos.where((r) => !r.completado).toList();
  }

  Future<List<Recordatorio>> getByCultivo(int cultivoId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?cultivo_id=$cultivoId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Recordatorio.fromJson(e)).toList();
    }
    throw Exception(_mensajeError(response));
  }

  Future<void> create(Recordatorio r) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode(r.toJson()),
    );
    if (response.statusCode != 201) throw Exception(_mensajeError(response));
  }

  Future<void> update(int id, Recordatorio r) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
      body: jsonEncode(r.toUpdateJson()),
    );
    if (response.statusCode != 200) throw Exception(_mensajeError(response));
  }

  Future<void> completar(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
      body: jsonEncode({'completado': true}),
    );
    if (response.statusCode != 200) throw Exception(_mensajeError(response));
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
    );
    if (response.statusCode != 200) throw Exception(_mensajeError(response));
  }
}
