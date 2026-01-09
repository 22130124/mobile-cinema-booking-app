import 'dart:convert';

import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/user/update_user_request.dart';
import 'package:frontend/storage/jwt_token_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://10.0.2.2:8080";
  // Cập nhật thông tin hồ sơ người dùng
  Future<void> updateProfile(UpdateUserRequest request) async {
    final url = Uri.parse('$baseUrl/users');
    final jwtToken = await JwtTokenStorage.getToken();
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwtToken",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body
          : '${response.statusCode} ${response.reasonPhrase}';
      throw message;
    }
  }
}