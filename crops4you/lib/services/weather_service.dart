import 'dart:convert';
import 'package:crops4you/config/api_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = '${ApiConfig.backendBaseUrl}/clima';

  // Obtener ubicación actual del dispositivo
  Future<Position> obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El servicio de ubicación está desactivado');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación denegado permanentemente. Actívalo en configuración.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  String _mensajeError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['mensaje'] != null) return body['mensaje'];
    } catch (_) {}
    return 'Error al obtener el clima: ${response.statusCode}';
  }

  // Obtener clima actual
  Future<Map<String, dynamic>> getClimaActual(double lat, double lng) async {
    final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lng');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_mensajeError(response));
  }

  // Obtener pronóstico 5 días
  Future<Map<String, dynamic>> getPronostico(double lat, double lng) async {
    final url = Uri.parse('$_baseUrl/pronostico?lat=$lat&lon=$lng');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_mensajeError(response));
  }
}
