// URL backend, config chung
// const String BASE_URL = 'http://localhost:8081/api';

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

const bool kUseAdbReverse = false;
const String kAndroidHost = kUseAdbReverse ? '127.0.0.1' : '10.0.2.2';

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080/api'; // Dành cho Chrome/Web
  } else if (Platform.isAndroid) {
    return 'http://$kAndroidHost:8080/api'; // Dành cho Android device (adb reverse) or emulator
  } else {
    return 'http://localhost:8080/api'; // Dành cho iOS Simulator hoặc Desktop app
  }
}

String getAuthBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080'; // Chrome/Web
  } else if (Platform.isAndroid) {
    return 'http://$kAndroidHost:8080'; // Android device (adb reverse) or emulator
  } else {
    return 'http://localhost:8080'; // iOS Simulator or Desktop app
  }
}

final String BASE_URL = getBaseUrl();
final String AUTH_BASE_URL = getAuthBaseUrl();
