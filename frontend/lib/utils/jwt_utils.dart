import 'dart:convert';

Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw Exception('Invalid JWT');
  final payload = base64Url.normalize(parts[1]);
  final decoded = utf8.decode(base64Url.decode(payload));
  return jsonDecode(decoded) as Map<String, dynamic>;
}

bool isAdminRoleFromToken(String token) {
  final payload = decodeJwtPayload(token);
  final role = payload['role'];
  return role == 'ADMIN' || role =='ROLE_ADMIN';
}
