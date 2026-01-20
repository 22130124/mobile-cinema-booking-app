import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

// Dropdown dùng chung cho nhiều kiểu dữ liệu (generic <T>)
class Dropdown<T> extends StatelessWidget {
  final T? value; // Giá trị đang được chọn (có thể null)
  final Map<T?, String> items;  // Danh sách item: key là value, value là text hiển thị
  final ValueChanged<T?> onChanged; // Callback khi người dùng chọn item khác

  const Dropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Chiều cao cố định cho dropdown
      height: 40,
      // Padding ngang cho nội dung bên trong
      padding: const EdgeInsets.symmetric(horizontal: 12),
      // Style khung dropdown
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      // Ẩn gạch chân mặc định của DropdownButton
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          // Giá trị đang được chọn
          value: value,
          dropdownColor: AppColors.backgroundCard,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),

          // Style chữ hiển thị trên nút
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          // Convert Map<T?, String> thành list DropdownMenuItem
          items: items.entries.map((e) {
            return DropdownMenuItem<T?>(
              value: e.key,
              child: Text(
                e.value,
                style: const TextStyle(color: AppColors.textPrimary), // Fix lỗi màu chữ
              ),
            );
          }).toList(),
          // Gọi callback khi chọn item
          onChanged: onChanged,
        ),
      ),
    );
  }
}