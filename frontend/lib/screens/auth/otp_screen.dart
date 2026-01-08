import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/reset_password_screen.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String type;

  const OtpScreen({super.key, required this.email, required this.type});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  bool _isLoadingConfirm = false;
  bool _isLoadingResend = false;
  int _resendCountdown = 0;
  Timer? _timer;

  // Phương thức phục vụ đếm ngược thời gian gửi lại mã OTP
  void _startCountdown() {
    setState(() {
      _resendCountdown = 60; // đếm ngược 60s
    });

    _timer?.cancel(); // cancel nếu đã có timer cũ
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

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
              "Xác Thực OTP",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Chúng tôi đã gửi mã xác nhận đến email:\n${widget.email}",
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
                onPressed: (_isLoadingResend || _resendCountdown > 0)
                    ? null
                    : () async {
                        // Hiển thị biểu tượng loading trong lúc gọi API
                        setState(() => _isLoadingResend = true);
                        try {
                          // Gọi API resend OTP
                          await AuthService().resendOtp(widget.email);
                          // Kiểm tra nếu context không còn sống thì không làm gì cả
                          if (!context.mounted) return;
                          // Hiển thị thông báo đã gửi lại mã OTP thành công
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã gửi lại mã OTP mới!"),
                            ),
                          );
                          // Đếm ngược 60 giây cho lần gửi lại mã OTP sau
                          _startCountdown();
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          if (context.mounted) {
                            setState(() => _isLoadingResend = false);
                          }
                        }
                      },
                child: (_resendCountdown > 0)
                    ? Text(
                        "Gửi lại sau $_resendCountdown giây",
                        style: const TextStyle(color: Colors.grey),
                      )
                    : (_isLoadingResend
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.amber,
                              ),
                            )
                          : const Text(
                              "Chưa nhận được mã? Gửi lại",
                              style: TextStyle(color: Colors.amber),
                            )),
              ),
            ),

            const SizedBox(height: 30),
            CustomButton(
              text: "Xác Nhận",
              onTapAsync: _isLoadingConfirm
                  ? null
                  : () async {
                      final otp = otpController.text.trim();
                      // Kiểm tra nếu chưa nhập mã OTP
                      if (otp.isEmpty) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập OTP")),
                        );
                        return;
                      }
                      // Hiển thị biểu tượng loading trong khi gọi API
                      setState(() => _isLoadingConfirm = true);
                      try {
                        // Gọi API xác thực mã OTP
                        final result = await AuthService().verifyOtp(
                          widget.email,
                          otp,
                        );
                        if (!context.mounted) return;

                        // Hiển thị thông báo xác minh thành công
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Xác minh OTP thành công!"),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Delay một chút trước khi chuyển trang để người
                        // dùng kịp nhìn thấy thông báo
                        await Future.delayed(const Duration(seconds: 2));

                        // Nếu OTP đúng, chuyển sang trang login
                        if (!context.mounted) return; //
                        switch (widget.type) {
                          case "register":
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                            break;
                          case "forgot_password":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen(
                                  email: widget.email,
                                  token: result,
                                ),
                              ),
                            );
                            break;
                          default:
                            break;
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      } finally {
                        if (context.mounted) {
                          setState(() => _isLoadingConfirm = false);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
