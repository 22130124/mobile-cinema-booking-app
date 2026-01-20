import 'dart:convert';

/// Giải mã JWT token và trả về payload
Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded) as Map<String, dynamic>;
  } catch (e) {
    return null;
  }
}

/// Kiểm tra xem token có phải của Admin không
bool isAdminRoleFromToken(String token) {
  final payload = decodeJwtPayload(token);
  if (payload == null) return false;

  final role = payload['role'] ?? payload['roles'] ?? payload['authorities'];
  
  if (role == null) return false;
  
  if (role is String) {
    return role.toUpperCase() == 'ADMIN' || role.toUpperCase() == 'ROLE_ADMIN';
  }
  
  if (role is List) {
    return role.any((r) {
      final roleStr = r.toString().toUpperCase();
      return roleStr == 'ADMIN' || roleStr == 'ROLE_ADMIN';
    });
  }
  
  return false;
}

/// Lấy email/username từ token
String? getEmailFromToken(String token) {
  final payload = decodeJwtPayload(token);
  if (payload == null) return null;
  
  return payload['sub'] ?? payload['email'] ?? payload['username'];
}

/// Kiểm tra token đã hết hạn chưa
bool isTokenExpired(String token) {
  final payload = decodeJwtPayload(token);
  if (payload == null) return true;
  
  final exp = payload['exp'];
  if (exp == null) return false;
  
  final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  return DateTime.now().isAfter(expiry);
}
