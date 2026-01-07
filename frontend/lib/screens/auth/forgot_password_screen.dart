import 'package:flutter/material.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

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
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
                icon: Icons.email_outlined
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Gửi Mã Xác Nhận",
              onTapSync: () {
                // TODO: Gọi Service Forgot Pass
                // Chuyển sang màn hình nhập OTP, truyền email vừa nhập qua
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OtpScreen(email: emailController.text)
                    )
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}