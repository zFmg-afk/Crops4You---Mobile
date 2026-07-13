import 'dart:convert';
import 'package:crops4you/config/api_config.dart';
import 'package:crops4you/main.dart';
import 'package:crops4you/models/parcela.dart';
import 'package:http/http.dart' as http;

class ParcelaService {
  final String _baseUrl = '${ApiConfig.backendBaseUrl}/parcelas';

  String? get _userId => supabase.auth.currentUser?.id;

  Future<List<Parcela>> getAll() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado');
    final response = await http.get(
      Uri.parse('$_baseUrl?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Parcela.fromJson(e)).toList();
    }
    throw Exception(_mensajeError(response));
  }

  Future<void> create(Parcela parcela) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado');
    final body = parcela.toJson();
    body['user_id'] = userId;
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
  }

  Future<void> update(int id, Parcela parcela) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parcela.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
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
