import 'package:jwt_decoder/jwt_decoder.dart';
import '../storage/jwt_token_storage.dart';

class JwtUtil {
  /// Lấy token từ secure storage
  static Future<String?> _getToken() async {
    return await JwtTokenStorage.getToken();
  }

  /// Decode payload
  static Future<Map<String, dynamic>?> decode() async {
    final token = await _getToken();
    if (token == null) return null;
    return JwtDecoder.decode(token);
  }

  /// Lấy userId (sub)
  static Future<int?> getUserId() async {
    final decoded = await decode();
    if (decoded == null) return null;

    final sub = decoded['sub'];
    return sub != null ? int.tryParse(sub.toString()) : null;
  }

  /// Lấy email
  static Future<String?> getEmail() async {
    final decoded = await decode();
    return decoded?['email'];
  }

  /// Lấy role
  static Future<String?> getRole() async {
    final decoded = await decode();
    return decoded?['role'];
  }

  /// Kiểm tra token hết hạn
  static Future<bool> isExpired() async {
    final token = await _getToken();
    if (token == null) return true;
    return JwtDecoder.isExpired(token);
  }

  /// Lấy thời gian hết hạn
  static Future<DateTime?> getExpirationDate() async {
    final token = await _getToken();
    if (token == null) return null;
    return JwtDecoder.getExpirationDate(token);
  }
}