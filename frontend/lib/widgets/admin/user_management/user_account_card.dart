import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../dtos/admin/admin_user_management/user_account.dart';

class UserAccountCard extends StatelessWidget {
  final UserAccount user; // Thông tin user_profile cần hiển thị
  final VoidCallback onEdit; // Callback khi bấm sửa thông tin
  final VoidCallback onLockToggle; // Callback khi bấm khóa / mở khóa tài khoản
  final VoidCallback onTap; // Callback khi bấm vào toàn bộ card

  const UserAccountCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onLockToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra tài khoản có đang bị khóa không
    bool isLocked = user.accountStatus == 'INACTIVE';
    // Kiểm tra user_profile có avatar hay không
    final bool hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

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
                  // Nếu có avatar thì load từ network
                  // Vì url là một ảnh trên internet không phải ảnh trong app
                  backgroundImage: hasAvatar
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: hasAvatar
                      ? null
                      : const Icon(
                          // Nếu không có avatar thì hiển thị icon mặc định
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
                        user.fullName.isNotEmpty
                            ? user.fullName
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
                          _tag(user.role),
                          _tag(user.accountStatus),
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
                    if (value == 'edit') onEdit();
                    if (value == 'lock') onLockToggle();
                  },
                  itemBuilder: (context) => [
                    // Menu sửa thông tin
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sửa thông tin',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    // Menu khóa / mở khóa
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
                            style: TextStyle(
                              color: isLocked ? Colors.green : Colors.red,
                            ),
                          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
