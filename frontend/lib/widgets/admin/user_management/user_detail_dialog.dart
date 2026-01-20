import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../model/admin/admin_user_management/user_info.dart';

// Dialog hiển thị chi tiết thông tin người dùng
class UserDetailDialog extends StatelessWidget {
  final UserInfo user; // Thông tin user_profile cần hiển thị
  final VoidCallback? onEdit; // Cho phép bấm sửa ngay từ màn hình chi tiết

  const UserDetailDialog({super.key, required this.user, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    return Dialog(
      // Màu nền dialog
      backgroundColor: AppColors.background,
      // Bo góc dialog
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Giới hạn chiều rộng dialog
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== HEADER: AVATAR + TÊN + ROLE =====
                Center(
                  child: Column(
                    children: [
                      // Avatar (tạm dùng icon nếu chưa có ảnh)
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
                      const SizedBox(height: 16),
                      // Tên người dùng
                      Text(
                        user.fullName?.isNotEmpty == true
                            ? user.fullName!
                            : 'Chưa cập nhật',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Role & trạng thái tài khoản
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _statusBadge(
                            user.role ?? 'Chưa cập nhật',
                            Colors.blue,
                          ),
                          _statusBadge(
                            user.accountStatus ?? 'Chưa cập nhật',
                            user.accountStatus == 'ACTIVE'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),

                // ===== THÔNG TIN CHI TIẾT =====
                _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Số điện thoại',
                  user.phone?.isNotEmpty == true
                      ? user.phone!
                      : 'Chưa cập nhật',
                ),

                _buildInfoRow(
                  Icons.wc,
                  'Giới tính',
                  user.gender == 'MALE'
                      ? 'Nam'
                      : user.gender == 'FEMALE'
                      ? 'Nữ'
                      : 'Chưa cập nhật',
                ),

                _buildInfoRow(
                  Icons.verified_user_outlined,
                  'Trạng thái hồ sơ',
                  user.userStatus ?? 'Chưa cập nhật',
                ),
                _buildInfoRow(Icons.key, 'ID Hệ thống', '#${user.id}'),

                const SizedBox(height: 24),

                // ===== NÚT ĐÓNG =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundCard,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),

                // ===== NÚT SỬA NHANH =====
                if (onEdit != null) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Đóng detail trước
                      onEdit!(); // Mở form sửa
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    label: const Text(
                      'Chỉnh sửa thông tin này',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Row hiển thị 1 dòng thông tin (icon + label + value)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon mô tả
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                // Value
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Badge hiển thị trạng thái / role
  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
