import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

// Dialog xác nhận hành động (xóa, khóa tài khoản, submit, ...)
class ConfirmationDialog extends StatelessWidget {
  final String title; // Tiêu đề dialog
  final String content; // Nội dung mô tả hành động cần xác nhận
  final VoidCallback onConfirm; // Callback khi người dùng bấm "Xác nhận"

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Màu nền dialog
      backgroundColor: AppColors.backgroundCard,
      // Tiêu đề
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      // Nội dung
      content: Text(content, style: const TextStyle(color: AppColors.textSecondary)),
      // Các nút hành động
      actions: [
        // Nút Hủy: đóng dialog
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
        ),
        // Nút Xác nhận: thực hiện action rồi đóng dialog
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          // Gọi callback xác nhận
          onPressed: () {
            onConfirm();
            Navigator.pop(context); // Đóng dialog sau khi xác nhận
          },
          child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}