import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import '../../widgets/auth/custom_button.dart';
import '../../widgets/auth/custom_textfield.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    bool _isLoading = false;

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
              "Quên Mật Khẩu?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Đừng lo! Hãy nhập email của bạn, chúng tôi sẽ gửi mã đặt lại mật khẩu.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Text("Email", style: TextStyle(color: Colors.white70)),
            CustomTextField(
              controller: emailController,
              hintText: "Nhập email của bạn",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Gửi Mã Xác Nhận",
              isLoading: _isLoading,
              onTapAsync: () async {
                final email = emailController.text;
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập email")),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  AuthService().forgotPassword(email);

                  // Kiểm tra context còn sống hay không
                  if (!context.mounted) return;

                  // Nếu thành công thì chuyển sang trang OTP
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpScreen(email: email, type: "register"),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                } finally {
                  if (context.mounted) setState(() => _isLoading = false);
                }

                // Chuyển sang màn hình nhập OTP, truyền email vừa nhập qua
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpScreen(
                      email: emailController.text,
                      type: "forgot_password",
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
