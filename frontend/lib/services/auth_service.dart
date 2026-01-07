import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080";

  // Đăng nhập tài khoản
  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      // Lấy trực tiếp body
      final message = response.body.isNotEmpty
          ? response.body
          : '${response.statusCode} ${response.reasonPhrase}';
      throw message;
    }

    // Khi đăng nhập thành công, backend sẽ trả về một jwt token
    String jwtToken = response.body;
    return jwtToken;
  }

  // Đăng ký tài khoản
  Future<void> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      // Lấy trực tiếp body
      final message = response.body.isNotEmpty
          ? response.body
          : '${response.statusCode} ${response.reasonPhrase}';
      throw message;
    }
  }

  // Xác thực OTP
  Future<String> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body
          : 'OTP không hợp lệ hoặc đã hết hạn';
      throw message;
    }

    // Nếu xác thực OTP cho chức năng quên mật khẩu
    // Thì API sẽ trả về một token để phục vụ cho việc đặt lại mật khẩu
    // Còn nếu là xác thực OTP cho chức năng đăng ký thì sẽ trả về null
    return response.body;
  }

  // Gửi lại OTP
  Future<void> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/auth/resend-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "type": "register"}),
    );

    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Không thể gửi lại OTP. Vui lòng thử lại sau';
      throw message;
    }
  }

  // Quên mật khẩu
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Không thể gửi mã xác nhận. Vui lòng thử lại sau';
      throw message;
    }
  }

  // Đặt lại mật khẩu (chức năng quên mật khẩu)
  Future<void> resetPassword(
    String email,
    String token,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "token": token, "password": password}),
    );

    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Không thể đặt lại mật khẩu. Vui lòng thử lại sau';
      throw message;
    }
  }
}
