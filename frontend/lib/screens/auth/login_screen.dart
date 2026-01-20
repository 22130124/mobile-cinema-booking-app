import 'package:flutter/material.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/utils/auth_handler.dart';
import '../../widgets/auth/google_login_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import '../../widgets/auth/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoginLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chào Mừng Quay Trở Lại!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Rất Vui Khi Gặp Bạn",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Tài Khoản",
                    style: TextStyle(color: Colors.white70),
                  ),
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Mật Khẩu",
                    style: TextStyle(color: Colors.white70),
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Mật khẩu",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: _isObscure,
                    onTogglePassword: () =>
                        setState(() => _isObscure = !_isObscure),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Quên Mật Khẩu?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomButton(
                    text: "Đăng Nhập",
                    isLoading: _isLoginLoading,
                    onTapAsync: () async {
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      // Kiểm tra thông tin nhập vào
                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng nhập đầy đủ thông tin"),
                          ),
                        );
                        return;
                      }

                      // Hiển thị biểu tượng loading trong lúc gọi API
                      setState(() => _isLoginLoading = true);
                      try {
                        // Gọi API đăng nhập tài khoản
                        final result = await AuthService().login(
                          email,
                          password,
                        );

                        await AuthHandler.handleLoginSuccess(
                          context: context,
                          jwtToken: result.jwtToken,
                          userStatus: result.userStatus,
                          accountStatus: result.accountStatus,
                          emailForOtp: _emailController.text,
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));

                        debugPrint(e.toString());
                      } finally {
                        if (context.mounted)
                          setState(() => _isLoginLoading = false);
                      }
                    },
                  ),

                  const SizedBox(height: 25),

                  // --- Phần phân cách "Hoặc" ---
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Hoặc",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- Nút Đăng nhập Google ---
                  const GoogleLoginButton(),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bạn chưa có tài khoản? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Đăng Ký",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
