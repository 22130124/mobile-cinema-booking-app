import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtTokenStorage {
  static const _key = 'jwt_token';
  static const _userIdKey = 'user_id';

  static FlutterSecureStorage _storage() {
    return const FlutterSecureStorage();
  }

  static Future<void> saveToken(String token) async {
    final storage = _storage();
    await storage.write(key: _key, value: token);
  }

  static Future<void> saveUserId(int userId) async {
    final storage = _storage();
    await storage.write(key: _userIdKey, value: userId.toString());
  }

  static Future<String?> getToken() async {
    final storage = _storage();
    return await storage.read(key: _key);
  }

  static Future<int?> getUserId() async {
    final storage = _storage();
    final value = await storage.read(key: _userIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  static Future<void> clear() async {
    final storage = _storage();
    await storage.delete(key: _key);
    await storage.delete(key: _userIdKey);
  }
}
