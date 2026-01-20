import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../storage/jwt_token_storage.dart';
import '../screens/home/home_screen.dart';
import '../screens/admin/admin_user_management_screen.dart';
import '../screens/user/profile_info_screen.dart';
import '../screens/auth/otp_screen.dart';

class AuthHandler {
  static Future<void> handleLoginSuccess({
    required BuildContext context,
    required String jwtToken,
    required bool userStatus,
    required String accountStatus,
    required String emailForOtp, // Cần email nếu phải verify OTP
  }) async {
    // Nếu tài khoản chưa được xác minh thì chuyển qua trang OTP
    if (accountStatus == 'UNVERIFIED') {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: emailForOtp,
            type: "verify_email",
          ),
        ),
      );
      return;
    }

    // Lưu token
    await JwtTokenStorage.saveToken(jwtToken);

    if (!context.mounted) return;

    // ecode JWT để lấy Role
    Map<String, dynamic> payload;
    try {
      payload = JwtDecoder.decode(jwtToken);
    } catch (e) {
      // Xử lý nếu token lỗi
      return;
    }
    final role = payload['role'] ?? 'USER';

    // Điều hướng dựa trên Role và User Status
    switch (role) {
      case "USER":
        if (userStatus == false) {
          // User chưa cập nhật hồ sơ
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ProfileInfoScreen()),
                (_) => false,
          );
        } else {
          // User đã đầy đủ thông tin
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
          );
        }
        break;

      case "ADMIN":
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()),
              (_) => false,
        );
        break;

      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
        );
    }
  }
}