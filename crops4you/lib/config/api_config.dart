import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get backendBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://10.0.2.2:3000';
  }
}
