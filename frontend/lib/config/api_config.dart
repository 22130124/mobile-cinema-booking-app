// URL backend, config chung
// const String BASE_URL = 'http://localhost:8081/api';

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080/api'; // Dành cho Chrome/Web
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080/api'; // Dành cho Android Emulator
  } else {
    return 'http://localhost:8080/api'; // Dành cho iOS Simulator hoặc Desktop app
  }
}

final String BASE_URL = getBaseUrl();


class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
