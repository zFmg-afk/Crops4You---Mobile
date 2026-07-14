import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get backendBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://10.0.2.2:3000';
  }

  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
}
