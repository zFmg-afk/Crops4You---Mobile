import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crops4you/config/api_config.dart';
import 'package:crops4you/main.dart';
import 'package:crops4you/models/cultivo.dart';

class CultivoService {
  final String _baseUrl = '${ApiConfig.backendBaseUrl}/cultivos';

  Map<String, String> _headers() {
    final session = supabase.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Cultivo>> getAll() async {
    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: _headers(),
    );
    if (res.statusCode != 200) _throwError(res);
    final List data = jsonDecode(res.body);
    return data.map((e) => Cultivo.fromJson(e)).toList();
  }

  Future<List<Cultivo>> getAllConParcela() async {
    return getAll();
  }

  Future<List<Cultivo>> getByParcela(int parcelaId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl?parcela_id=$parcelaId'),
      headers: _headers(),
    );
    if (res.statusCode != 200) _throwError(res);
    final List data = jsonDecode(res.body);
    return data.map((e) => Cultivo.fromJson(e)).toList();
  }

  Future<void> create(Cultivo cultivo) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode(cultivo.toJson()),
    );
    if (res.statusCode != 201) _throwError(res);
  }

  Future<void> update(int id, Cultivo cultivo) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
      body: jsonEncode(cultivo.toJson()),
    );
    if (res.statusCode != 200) _throwError(res);
  }

  Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(),
    );
    if (res.statusCode != 204) _throwError(res);
  }

  void _throwError(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    throw Exception(body['mensaje'] ?? 'Error ${res.statusCode}');
  }
}
