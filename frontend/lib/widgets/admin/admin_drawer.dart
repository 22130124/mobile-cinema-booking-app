import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../storage/jwt_token_storage.dart';
import '../../screens/auth/login_screen.dart';

/// Menu item
class AdminMenuItem {
  final String title;
  final IconData icon;
  final String routeKey;
  final bool isAvailable; // false = "Đang phát triển"

  const AdminMenuItem({
    required this.title,
    required this.icon,
    required this.routeKey,
    this.isAvailable = false,
  });
}

/// Side Menu
class AdminDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String routeKey) onMenuTap;

  const AdminDrawer({
    super.key,
    required this.currentRoute,
    required this.onMenuTap,
  });

  static const List<AdminMenuItem> menuItems = [
    AdminMenuItem(
      title: 'Báo cáo thống kê',
      icon: Icons.dashboard_outlined,
      routeKey: 'dashboard',
      isAvailable: true, // Đã có
    ),
    AdminMenuItem(
      title: 'Quản lý trailer',
      icon: Icons.movie_outlined,
      routeKey: 'trailers',
      isAvailable: true, // Đã có
    ),
    AdminMenuItem(
      title: 'Quản lý người dùng',
      icon: Icons.people_outlined,
      routeKey: 'users',
      isAvailable: false,
    ),
    AdminMenuItem(
      title: 'Quản lý danh sách phim',
      icon: Icons.video_library_outlined,
      routeKey: 'movies',
      isAvailable: true,
    ),
    AdminMenuItem(
      title: 'Quản lý rạp chiếu',
      icon: Icons.location_city_outlined,
      routeKey: 'cinemas',
      isAvailable: true,
    ),
    AdminMenuItem(
      title: 'Quản lý đơn hàng',
      icon: Icons.receipt_long_outlined,
      routeKey: 'orders',
      isAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            const Divider(color: AppColors.border, height: 1),
            
            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isActive = currentRoute == item.routeKey;
                  
                  return _buildMenuItem(
                    context: context,
                    item: item,
                    isActive: isActive,
                  );
                },
              ),
            ),
            
            const Divider(color: AppColors.border, height: 1),
            
            // Logout button
            _buildLogoutButton(context),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.movie_filter,
              color: Colors.black,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          const Text(
            'Cinema Admin',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtitle
          const Text(
            'Quản lý hệ thống',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required AdminMenuItem item,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive 
            ? AppColors.accent.withOpacity(0.15) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!item.isAvailable) {
              Navigator.pop(context); // Đóng drawer
              _showComingSoonDialog(context, item.title);
              return;
            }
            
            // Gọi callback - callback sẽ tự đóng drawer
            onMenuTap(item.routeKey);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isActive 
                      ? AppColors.accent 
                      : (item.isAvailable 
                          ? AppColors.textSecondary 
                          : AppColors.textHint),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: isActive 
                          ? AppColors.accent 
                          : (item.isAvailable 
                              ? AppColors.textPrimary 
                              : AppColors.textHint),
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (!item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Soon',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleLogout(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: const [
                Icon(
                  Icons.logout_outlined,
                  color: AppColors.error,
                  size: 22,
                ),
                SizedBox(width: 14),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.construction, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Text(
              'Đang phát triển',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Chức năng "$featureName" sẽ được cập nhật trong phiên bản tiếp theo.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await JwtTokenStorage.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
