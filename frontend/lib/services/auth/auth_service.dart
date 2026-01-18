import 'dart:convert';
import 'package:frontend/dtos/auth/login_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080/api/auth";

  // Đăng nhập tài khoản
  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
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

    // Khi đăng nhập thành công, backend sẽ trả về jwt token và userStatus
    // userStatus: trạng thái cho biết hồ sơ người dùng đã hoàn thiện chưa
    // Parse JSON từ backend
    final Map<String, dynamic> data = jsonDecode(response.body);
    return LoginResponse.fromJson(data);
  }

  // Đăng nhập bằng Google
  Future<LoginResponse> loginWithGoogle(String idToken) async {
    final url = Uri.parse('$baseUrl/google-login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body
          : '${response.statusCode} ${response.reasonPhrase}';
      throw message;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return LoginResponse.fromJson(data);
  }

  // Đăng ký tài khoản
  Future<void> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
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
    final url = Uri.parse('$baseUrl/verify-otp');
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
    final url = Uri.parse('$baseUrl/resend-otp');
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
    final url = Uri.parse('$baseUrl/forgot-password');
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
    final url = Uri.parse('$baseUrl/reset-password');
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
