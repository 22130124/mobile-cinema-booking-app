import 'package:flutter/material.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Đặt Lại Mật Khẩu", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Tạo mật khẩu mới cho tài khoản của bạn.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Nhập mật khẩu mới
              Align(alignment: Alignment.centerLeft, child: const Text("Mật Khẩu Mới", style: TextStyle(color: Colors.white70))),
              CustomTextField(
                controller: _newPassController,
                hintText: "Nhập mật khẩu mới",
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: _isObscure,
                onTogglePassword: () => setState(() => _isObscure = !_isObscure),
              ),

              // Xác nhận mật khẩu
              Align(alignment: Alignment.centerLeft, child: const Text("Xác Nhận Mật Khẩu", style: TextStyle(color: Colors.white70))),
              CustomTextField(
                controller: _confirmPassController,
                hintText: "Nhập lại mật khẩu mới",
                icon: Icons.lock_clock_outlined, // Icon khác một chút
                isPassword: true,
                isObscure: _isObscure,
                onTogglePassword: () => setState(() => _isObscure = !_isObscure),
              ),

              const SizedBox(height: 40),
              CustomButton(
                text: "Lưu Mật Khẩu",
                onTap: () {
                  // TODO: Gọi API Cập nhật mật khẩu mới

                  // Hiển thị thông báo thành công
                  showDialog(
                      context: context,
                      barrierDismissible: false, // Bắt buộc bấm nút để đóng
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2C2C2C),
                        title: const Text("Thành Công", style: TextStyle(color: Colors.white)),
                        content: const Text("Mật khẩu của bạn đã được thay đổi. Vui lòng đăng nhập lại.", style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Xóa hết các màn hình cũ trong stack và về Login
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                              );
                            },
                            child: const Text("Về Đăng Nhập", style: TextStyle(color: Colors.amber)),
                          )
                        ],
                      )
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}