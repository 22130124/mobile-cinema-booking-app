import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import '../../widgets/auth/social_button.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bắt Đầu Đăng Ký Miễn Phí",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Miễn phí mãi mãi. Không cần thẻ tín dụng",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              const Text("Email", style: TextStyle(color: Colors.white70)),
              CustomTextField(
                controller: _emailController,
                hintText: "yourname@gmail.com",
                icon: Icons.email_outlined,
              ),

              const Text("Mật Khẩu", style: TextStyle(color: Colors.white70)),
              CustomTextField(
                controller: _passController,
                hintText: "Nhập mật khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: _isObscure,
                onTogglePassword: () =>
                    setState(() => _isObscure = !_isObscure),
              ),

              const Text(
                "Nhập Lại Mật Khẩu",
                style: TextStyle(color: Colors.white70),
              ),
              CustomTextField(
                controller: _confirmPassController,
                hintText: "Nhập lại mật khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: _isObscure,
                onTogglePassword: () =>
                    setState(() => _isObscure = !_isObscure),
              ),

              const SizedBox(height: 30),
              CustomButton(
                text: "Đăng Ký",
                isLoading: _isLoading,
                onTapAsync: () async {
                  final email = _emailController.text;
                  final pass = _passController.text;
                  final confirmPass = _confirmPassController.text;

                  // Kiểm tra thông tin nhập vào
                  if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
                    );
                    return;
                  }

                  // Kiểm tra mật khẩu có khớp hay không
                  if (pass != confirmPass) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mật khẩu không trùng khớp")),
                    );
                    return;
                  }

                  // Hiển thị biểu tượng loading trong lúc gọi API
                  setState(() => _isLoading = true);

                  try {
                    await AuthService().register(email, pass);

                    // Kiểm tra context còn sống hay không
                    if (!context.mounted) return;

                    // Nếu thành công, chuyển sang màn hình OTP
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OtpScreen(email: email)),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),

              const SizedBox(height: 25),

              // Phần phân cách "Hoặc"
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Hoặc", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 25),

              // Nút Đăng nhập Google
              SocialButton(
                text: "Đăng nhập với Google",
                // Link icon Google
                iconUrl:
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                onTap: () {
                  // TODO: Tích hợp Google Sign In
                  print("Nhấn nút Google");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
