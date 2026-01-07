import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080";

  // Gọi API đăng ký tài khoản
  Future<void> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      // Lấy trực tiếp body
      final message = response.body.isNotEmpty ? response.body : '${response.statusCode} ${response.reasonPhrase}';
      throw message;
    }
  }
}
