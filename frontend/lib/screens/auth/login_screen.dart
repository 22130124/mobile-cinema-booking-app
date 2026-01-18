import 'package:flutter/material.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/user/profile_info_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/screens/home/main_screen.dart';
import '../../storage/jwt_token_storage.dart';
import '../admin/dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/social_button.dart';

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
  bool _isLoginGoogleLoading = false;
  late final GoogleSignIn _googleSignIn;
  bool _googleReady = false;

  @override
  void initState() {
    super.initState();

    _googleSignIn = GoogleSignIn.instance;
    _initGoogle();
  }

  Future<void> _initGoogle() async {
    await _googleSignIn.initialize(
      serverClientId:
          '134285940318-ig9smfp4usqoj3qqvilbnrm1fgruj7l2.apps.googleusercontent.com',
    );
    setState(() => _googleReady = true);
  }

  // Hàm xử lý khi đăng nhập (thường/google) thành công
  Future<void> _handleLoginSuccess({
    required String jwtToken, required bool? userStatus,
  }) async {
    // Decode JWT
    final payload = JwtDecoder.decode(jwtToken);
    final role = payload['role'] ?? 'USER';

    // Lưu token
    await JwtTokenStorage.saveToken(jwtToken);

    // Kiểm tra trạng thái context
    if (!mounted) return;

    // Dựa vào role để quyết định trang đích sẽ được chuyển đến
    switch (role) {
      case "USER":
        // Nếu là user mới đăng ký tài khoản thì sẽ chuyển vào trang hồ sơ người dùng
        if (userStatus == false) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ProfileInfoScreen()),
            (_) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
        break;

      case "ADMIN":
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (_) => false,
        );
        break;

      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
    }
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

                        // Lấy ra JWT Token từ kết quả trả về từ API
                        final jwtToken = result.jwtToken;
                        final userStatus = result.userStatus;

                        await _handleLoginSuccess(
                          jwtToken: jwtToken,
                          userStatus: userStatus,
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
                  SocialButton(
                    text: "Đăng nhập với Google",
                    // Link icon Google
                    iconUrl:
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                    onTapAsync: _googleReady ? () async {
                      // Hiển thị biểu tượng loading
                      setState(() => _isLoginGoogleLoading = true);

                      try {
                        // Dùng authenticate()
                        // Hàm này yêu cầu try-catch vì nó sẽ throw Exception nếu user hủy
                        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

                        // Lấy thông tin authentication (chứa idToken)
                        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

                        // Kiểm tra idToken
                        if (googleAuth.idToken == null) {
                          throw Exception("Không lấy được Google ID Token");
                        }

                        // Gửi idToken về Backend Spring Boot
                        final result = await AuthService().loginWithGoogle(googleAuth.idToken!);

                        // Xử lý nếu đăng nhập thành công
                        await _handleLoginSuccess(
                          jwtToken: result.jwtToken,
                          userStatus: result.userStatus,
                        );
                      } catch (e) {
                        // Xử lý lỗi hoặc người dùng hủy
                        print("Đăng nhập Google thất bại: $e");

                        if (!context.mounted) return;

                        // Nếu không phải do người dùng hủy thì mới hiện thông báo
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Đăng nhập thất bại: $e")));

                        debugPrint(e.toString());

                        // Logout để reset trạng thái
                        _googleSignIn.signOut();
                      } finally {
                        if (mounted) setState(() => _isLoginGoogleLoading = false);
                      }
                    } : null,
                    isLoading: _isLoginGoogleLoading,
                  ),

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
