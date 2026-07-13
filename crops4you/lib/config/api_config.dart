class ApiConfig {
  // Emulador Android usa 10.0.2.2 para apuntar al localhost de la PC.
  // iOS simulator/dispósitivo físico: usar 'http://localhost:3000' o la IP de la PC.
  static const String backendBaseUrl = 'http://10.0.2.2:3000';
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
}
