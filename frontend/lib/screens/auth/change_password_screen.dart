import 'package:flutter/material.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/utils/jwt_utils.dart';
import '../../widgets/auth/custom_button.dart';
import '../../widgets/auth/custom_textfield.dart';
import 'otp_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final oldPassController = TextEditingController();
    bool isLoading = false;

    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Đổi mật khẩu",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hãy nhập mật khẩu cũ của bạn",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text("Mật khẩu", style: TextStyle(color: Colors.white70)),
            CustomTextField(
              controller: oldPassController,
              hintText: "Nhập mật khẩu của bạn",
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Gửi Mã Xác Nhận",
              isLoading: isLoading,
              onTapAsync: () async {
                final oldPassword = oldPassController.text;
                if (oldPassword.isEmpty) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập mật khẩu cũ")),
                  );
                  return;
                }

                setState(() => isLoading = true);

                try {
                  final email = await JwtUtil.getEmail();
                  AuthService().ChangePassword(email!);

                  // Kiểm tra context còn sống hay không
                  if (!context.mounted) return;

                  // Nếu thành công thì chuyển sang trang OTP
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpScreen(email: email, type: "change_password"),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                } finally {
                  if (context.mounted) setState(() => isLoading = false);
                }

                // Chuyển sang màn hình nhập OTP, truyền email vừa nhập qua
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpScreen(
                      email: oldPassController.text,
                      type: "reset_password",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
