import 'package:flutter/material.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import 'login_screen.dart';

class OtpScreen extends StatelessWidget {
  final String email; // Nhận email từ màn hình trước để hiển thị

  const OtpScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

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
              "Xác Thực OTP",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Chúng tôi đã gửi mã xác nhận 6 số đến email:\n$email",
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),

            const Text("Nhập Mã OTP", style: TextStyle(color: Colors.white70)),
            CustomTextField(
              controller: otpController,
              hintText: "Ví dụ: 123456",
              icon: Icons.security,
            ),

            const SizedBox(height: 20),

            // Nút Gửi lại mã
            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã gửi lại mã mới!")),
                  );
                },
                child: const Text("Chưa nhận được mã? Gửi lại", style: TextStyle(color: Colors.amber)),
              ),
            ),

            const SizedBox(height: 30),
            CustomButton(
              text: "Xác Nhận",
              onTapSync: () {
                // TODO: Gọi API kiểm tra mã OTP đúng hay sai
                // Nếu đúng thì chuyển sang trang kế tiếp
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}