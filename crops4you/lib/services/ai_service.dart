import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum ModoAnalisis { cultivo, planta }

class AiService {
  final String _apiKey = dotenv.env['GEMINI_KEY'] ?? '';
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static const String _promptCultivo =
      '''Eres un experto agrónomo. Analiza esta imagen de un cultivo agrícola y proporciona:

1. Estado general del cultivo (saludable, enfermo, con estrés, etc.)
2. Posibles problemas detectados (plagas, enfermedades, deficiencias nutricionales, etc.)
3. Recomendaciones específicas para el agricultor
4. Nivel de urgencia (bajo, medio, alto)

Responde en español de forma clara y práctica. Si la imagen no muestra un cultivo, indícalo amablemente.''';

  static const String _promptPlanta =
      '''Eres un experto botánico. Identifica la planta en esta imagen y proporciona:

1. Nombre común y nombre científico (si es posible)
2. Características principales de la planta
3. ¿Es una planta de interior o exterior?
4. Cuidados básicos (luz, agua, temperatura)
5. Datos curiosos o usos comunes

Responde en español de forma clara y amigable. Si no puedes identificar la planta con certeza, da tu mejor aproximación. Sé conciso pero completo. No te excedas en detalles innecesarios.''';

  Future<String> analizarImagenCultivo(
    File imagen, {
    ModoAnalisis modo = ModoAnalisis.cultivo,
  }) async {
    final bytes = await imagen.readAsBytes();
    final base64Image = base64Encode(bytes);
    final extension = imagen.path.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

    final String prompt = modo == ModoAnalisis.cultivo
        ? _promptCultivo
        : _promptPlanta;

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 4096},
    };

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    }

    throw Exception('Error al analizar la imagen: ${response.statusCode}');
  }
}
