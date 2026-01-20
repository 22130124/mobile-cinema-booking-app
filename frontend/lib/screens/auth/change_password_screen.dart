import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/reset_password_screen.dart';
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
  final _oldPassController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
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
              controller: _oldPassController,
              hintText: "Nhập mật khẩu cũ của bạn",
              icon: Icons.lock_outline,
              isPassword: true,
              isObscure: _isObscure,
              onTogglePassword: () => setState(() => _isObscure = !_isObscure),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Kiểm tra",
              isLoading: _isLoading,
              onTapAsync: () async {
                final oldPassword = _oldPassController.text;
                if (oldPassword.isEmpty) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập mật khẩu cũ")),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  await AuthService().checkOldPassword(oldPassword);

                  // Kiểm tra context còn sống hay không
                  if (!context.mounted) return;

                  // Nếu thành công thì chuyển sang trang ResetPassword
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen(redirectScreen: "home"),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
