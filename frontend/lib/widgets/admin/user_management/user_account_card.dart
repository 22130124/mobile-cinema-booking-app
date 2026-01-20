import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../model/admin/admin_user_management/user_info.dart';

class UserAccountCard extends StatelessWidget {
  final UserInfo user; // Thông tin user_profile cần hiển thị
  final VoidCallback onEdit; // Callback khi bấm sửa thông tin
  final VoidCallback onLockToggle; // Callback khi bấm khóa / mở khóa tài khoản
  final VoidCallback onRoleToggle; // Callback phân quyền
  final VoidCallback onTap; // Callback khi bấm vào toàn bộ card

  const UserAccountCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onLockToggle,
    required this.onTap,
    required this.onRoleToggle,
  });

  @override
  Widget build(BuildContext context) {
    bool isLocked = user.accountStatus == 'INACTIVE';
    bool isUnverified = user.accountStatus == 'UNVERIFIED';
    final bool hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    bool isAdmin = user.role == 'ADMIN';

    return Card(
      color: AppColors.backgroundCard,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        // Bọc nội dung bằng InkWell để bắt sự kiện tap
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ===== AVATAR =====
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accent.withAlpha(38),
                  backgroundImage: hasAvatar
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: hasAvatar
                      ? null
                      : const Icon(
                    Icons.person,
                    color: AppColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),

                // ===== THÔNG TIN USER =====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên người dùng
                      Text(
                        user.fullName?.isNotEmpty == true
                            ? user.fullName!
                            : 'Chưa cập nhật',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      // Tag role & trạng thái tài khoản
                      Wrap(
                        spacing: 8,
                        children: [
                          _tag(user.role ?? 'Chưa cập nhật'),
                          _tag(user.accountStatus ?? 'Chưa cập nhật'),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== MENU HÀNH ĐỘNG =====
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.backgroundCard,
                  // Xử lý khi chọn menu
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'lock':
                        onLockToggle();
                        break;
                      case 'role_admin':
                        onRoleToggle();
                        break;
                      case 'role_user':
                        onRoleToggle();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    // Nhóm 1: Thao tác cơ bản
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text('Sửa thông tin', style: TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    if (!isUnverified)
                    PopupMenuItem(
                      value: 'lock',
                      child: Row(
                        children: [
                          Icon(
                            isLocked ? Icons.lock_open : Icons.lock_outline,
                            size: 18,
                            color: isLocked ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                            style: TextStyle(color: isLocked ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                    ),

                    // Nhóm 2: Phân quyền
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      enabled: false, // Mục này chỉ để hiển thị tiêu đề, không bấm được
                      height: 30,
                      child: Text(
                        'PHÂN QUYỀN',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'role_admin',
                      child: Row(
                        children: [
                          Icon(
                              Icons.admin_panel_settings,
                              size: 18,
                              // Nếu đang là Admin thì highlight màu
                              color: isAdmin ? AppColors.accent : AppColors.textPrimary
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Admin',
                            style: TextStyle(
                              // Nếu đang là Admin thì in đậm
                              color: isAdmin ? AppColors.accent : AppColors.textPrimary,
                              fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isAdmin) ...[
                            const Spacer(),
                            const Icon(Icons.check, size: 16, color: AppColors.accent),
                          ]
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'role_user',
                      child: Row(
                        children: [
                          Icon(
                              Icons.person_outline,
                              size: 18,
                              color: !isAdmin ? AppColors.accent : AppColors.textPrimary
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'User',
                            style: TextStyle(
                              color: !isAdmin ? AppColors.accent : AppColors.textPrimary,
                              fontWeight: !isAdmin ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (!isAdmin) ...[
                            const Spacer(),
                            const Icon(Icons.check, size: 16, color: AppColors.accent),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị tag (role, status)
  Widget _tag(String text) {
    Color tagColor;
    Color textColor;
    Color borderColor;

    switch (text) {
      case 'ADMIN':
        tagColor = AppColors.accent.withAlpha(25);
        textColor = AppColors.accent;
        borderColor = AppColors.accent;
        break;

      case 'USER':
        tagColor = Colors.blue.withAlpha(25);
        textColor = Colors.blue;
        borderColor = Colors.blue;
        break;

      case 'ACTIVE':
        tagColor = Colors.green.withAlpha(25);
        textColor = Colors.green;
        borderColor = Colors.green;
        break;

      case 'INACTIVE':
        tagColor = Colors.red.withAlpha(25);
        textColor = Colors.red;
        borderColor = Colors.red;
        break;

      case 'UNVERIFIED':
        tagColor = Colors.red.withAlpha(25);
        textColor = Colors.red;
        borderColor = Colors.red;
        break;

      default:
        tagColor = AppColors.surface;
        textColor = AppColors.textSecondary;
        borderColor = AppColors.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: text == 'ADMIN' ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}