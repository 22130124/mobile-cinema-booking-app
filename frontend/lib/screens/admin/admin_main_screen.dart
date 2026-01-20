import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_dashboard_screen.dart';
import 'admin_movies_screen.dart';
import 'admin_trailers_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  String _currentRoute = 'movies';
  
  // Map route key - title
  final Map<String, String> _titles = {
    'dashboard': 'Báo cáo thống kê',
    'trailers': 'Quản lý trailer',
    'users': 'Quản lý người dùng',
    'movies': 'Quản lý danh sách phim',
    'cinemas': 'Quản lý rạp chiếu',
    'orders': 'Quản lý đơn hàng',
  };

  // Map route key - icon
  final Map<String, IconData> _icons = {
    'dashboard': Icons.bar_chart_rounded,
    'trailers': Icons.movie_creation_outlined,
    'users': Icons.people_outline,
    'cinemas': Icons.theaters_outlined,
    'orders': Icons.receipt_long_outlined,
  };

  void _onMenuTap(String routeKey) {
    Navigator.pop(context); // Đóng drawer
    if (routeKey != _currentRoute) {
      setState(() {
        _currentRoute = routeKey;
      });
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentRoute) {
      case 'movies':
        return const AdminMoviesScreen(embedded: true);
      case 'dashboard':
        return const AdminDashboardContent();
      case 'trailers':
        return const AdminTrailersContent();
      default:
        return _ComingSoonContent(
          title: _titles[_currentRoute] ?? 'Chức năng',
          icon: _icons[_currentRoute] ?? Icons.construction,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AdminDrawer(
        currentRoute: _currentRoute,
        onMenuTap: _onMenuTap,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _titles[_currentRoute] ?? 'Admin',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_currentRoute == 'movies')
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.accent),
              onPressed: () {
                setState(() {});
              },
            ),
        ],
      ),
      body: _buildCurrentScreen(),
    );
  }
}

/// Placeholder cho cn chưa phát triển
class _ComingSoonContent extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonContent({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction,
                  size: 18,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Text(
                  'Đang phát triển',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Chức năng này sẽ được các thành viên\nkhác trong nhóm phát triển.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
