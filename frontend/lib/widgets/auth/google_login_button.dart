import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/auth/auth_service.dart';
import '../../utils/auth_handler.dart';
import 'social_button.dart';

class GoogleLoginButton extends StatefulWidget {
  const GoogleLoginButton({super.key});

  @override
  State<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  bool _isLoading = false;
  late final GoogleSignIn _googleSignIn;
  bool _googleReady = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn.instance;
    _initGoogle();
  }

  Future<void> _initGoogle() async {
    // Đảm bảo clientId khớp với cấu hình của bạn
    await _googleSignIn.initialize(
      serverClientId:
      '134285940318-ig9smfp4usqoj3qqvilbnrm1fgruj7l2.apps.googleusercontent.com',
    );
    if (mounted) setState(() => _googleReady = true);
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_googleReady) return;

    setState(() => _isLoading = true);

    try {
      // 1. Trigger Google Sign In Flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 2. Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("Không lấy được Google ID Token");
      }

      // 3. Gọi API Backend
      final result = await AuthService().loginWithGoogle(googleAuth.idToken!);

      if (!mounted) return;

      // 4. Sử dụng Helper để điều hướng
      await AuthHandler.handleLoginSuccess(
        context: context,
        jwtToken: result.jwtToken,
        userStatus: result.userStatus,
        accountStatus: result.accountStatus,
        emailForOtp: googleUser.email, // Google login thường đã verify, nhưng cứ truyền để safe
      );

    } catch (e) {
      if (!mounted) return;

      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập Google thất bại: $e")),
      );

      // Logout Google để reset trạng thái nếu lỗi
      _googleSignIn.signOut();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SocialButton(
      text: "Đăng nhập với Google",
      iconUrl:
      "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
      isLoading: _isLoading,
      onTapAsync: _googleReady ? _handleGoogleSignIn : null,
    );
  }
}