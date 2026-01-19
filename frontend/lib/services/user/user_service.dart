import 'dart:convert';

import 'package:frontend/config/api_config.dart';
import 'package:frontend/storage/jwt_token_storage.dart';
import 'package:http/http.dart' as http;

import '../../dtos/user_profile/update_user_profile_request.dart';


class UserService {
  final String baseUrl = '${getBaseUrl()}/users';
  // Cập nhật thông tin hồ sơ người dùng
  Future<void> updateProfile(UpdateUserProfileRequest request) async {
    final url = Uri.parse(baseUrl);
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