import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String _apiKey = dotenv.env['OPENWEATHER_KEY'] ?? '';

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

  // Obtener clima actual
  Future<Map<String, dynamic>> getClimaActual(double lat, double lng) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lng&appid=$_apiKey&units=metric&lang=es',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener el clima: ${response.statusCode}');
  }

  // Obtener pronóstico 5 días
  Future<Map<String, dynamic>> getPronostico(double lat, double lng) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lng&appid=$_apiKey&units=metric&lang=es&cnt=40',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener el pronóstico: ${response.statusCode}');
  }
}
