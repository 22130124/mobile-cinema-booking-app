import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/movie_service.dart';
import '../../model/movie_model.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import '../auth/login_screen.dart';
import '../order/order_history_screen.dart';
import '../../widgets/home/custom_bottom_nav.dart';
import '../../storage/jwt_token_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  int? _userId;
  bool _isLoadingUser = true;

  // Movies để truyền cho SearchScreen
  List<Movie> _movies = [];
  bool _isLoadingMovies = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadMovies();
  }

  Future<void> _loadUserId() async {
    final userId = await JwtTokenStorage.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _isLoadingUser = false;
    });
  }

  Future<void> _loadMovies() async {
    try {
      final movies = await MovieService.getAllMovies();
      if (mounted) {
        setState(() {
          _movies = movies;
          _isLoadingMovies = false;
        });
      }
    } on MovieServiceException catch (e) {
      print('MovieServiceException in MainScreen: $e');
      if (mounted) {
        setState(() {
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      print('Error loading movies: $e');
      if (mounted) {
        setState(() {
          _isLoadingMovies = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return _isLoadingMovies
            ? _buildLoadingScreen()
            : SearchScreen(movies: _movies, showBackButton: false);
      case 2:
        if (_isLoadingUser) {
          return _buildLoadingScreen();
        }
        if (_userId == null) {
          return _buildLoginRequired();
        }
        return OrderHistoryScreen(userId: _userId!);
      case 3:
        return _buildProfilePlaceholder();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }

  Widget _buildProfilePlaceholder() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Đã đăng nhập',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thông tin tài khoản của bạn',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            
            // Nút đăng xuất
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await JwtTokenStorage.clear();
                  
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Đăng Xuất',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Vui lòng đăng nhập để xem lịch sử',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
