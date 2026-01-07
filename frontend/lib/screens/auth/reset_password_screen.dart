import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({super.key, required this.email, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // In ra console khi vừa vào màn hình
    debugPrint("ResetPasswordScreen INIT");
    debugPrint("Email nhận được: ${widget.email}");
    debugPrint("Token nhận được: ${widget.token}");
  }

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
                isLoading: _isLoading,
                onTapAsync: () async {
                  final password = _newPassController.text;
                  final confirmPassword = _confirmPassController.text;

                  if (password.isEmpty || confirmPassword.isEmpty) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng nhập đầy đủ thông tin"),
                      ),
                    );
                    return;
                  }

                  if (password != confirmPassword) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mật khẩu không trùng khớp"),
                      ),
                    );
                    return;
                  }

                  // Hiển thị biểu tượng loading
                  setState(() => _isLoading = true);
                  try {
                    // Gọi API đặt lại mật khẩu
                    await AuthService().resetPassword(
                      widget.email,
                      widget.token,
                      _newPassController.text,
                    );

                    // Hiển thị thông báo đặt lại mật khẩu thành công
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đặt lại mật khẩu thành công!"),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Delay một chút trước khi chuyển trang để người
                    // dùng kịp nhìn thấy thông báo
                    await Future.delayed(const Duration(seconds: 2));

                    // Kiểm tra context còn sống hay không
                    if (!context.mounted) return;
                    // Quay về trang login
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  } finally {
                    if (context.mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}