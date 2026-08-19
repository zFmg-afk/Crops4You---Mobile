import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crops4you/config/api_config.dart';

enum ModoAnalisis { cultivo, planta }

class AiService {
  Future<String> analizarImagenCultivo(
    File imagen, {
    ModoAnalisis modo = ModoAnalisis.cultivo,
  }) async {
    final bytes = await imagen.readAsBytes();
    final base64Image = base64Encode(bytes);
    final extension = imagen.path.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final modoStr = modo == ModoAnalisis.cultivo ? 'cultivo' : 'planta';

    final response = await http
        .post(
          Uri.parse('${ApiConfig.backendBaseUrl}/ia/analisis'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'base64Image': base64Image,
            'mimeType': mimeType,
            'modo': modoStr,
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['resultado'];
    }

    throw Exception('Error al analizar la imagen: ${response.statusCode}');
  }
}
