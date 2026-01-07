import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtTokenStorage {
  static const _key = 'jwt_token';

  static FlutterSecureStorage _storage() {
    return const FlutterSecureStorage();
  }

  static Future<void> saveToken(String token) async {
    final storage = _storage();
    await storage.write(key: _key, value: token);
  }

  static Future<String?> getToken() async {
    final storage = _storage();
    return await storage.read(key: _key);
  }

  static Future<void> clear() async {
    final storage = _storage();
    await storage.delete(key: _key);
  }
}