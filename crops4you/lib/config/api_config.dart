import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get backendBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://172.30.66.153:3000';
  }
}
