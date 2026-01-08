import 'package:flutter/material.dart';

/// App Colors - Định nghĩa màu sắc cho toàn app. Để sau này thêm Dark Mode / Light Mode
class AppColors {
  // Màu nền chính
  static const Color background = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFF1A1A1A);
  static const Color backgroundCard = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF252525);
  
  // Màu text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF757575);
  
  // Màu accent/highlight
  static const Color primary = Color(0xFF6C63FF);  // Tím chủ đạo
  static const Color accent = Color(0xFFD4AF37);   // Vàng gold
  static const Color accentLight = Color(0xFFFDF5A6);
  
  // Màu trạng thái
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Màu cho các chip/badge
  static const Color chipNowShowing = Color(0xFF4CAF50);  // Xanh lá
  static const Color chipSpecial = Color(0xFF9C27B0);     // Tím
  static const Color chipComingSoon = Color(0xFFFF9800);  // Cam
  
  // Màu border/divider
  static const Color border = Color(0xFF333333);
  static const Color divider = Color(0xFF2A2A2A);
  
  // Màu cho search bar
  static const Color searchBackground = Color(0xFF2A2A2A);
  static const Color searchIcon = Color(0xFF757575);
  
  // Màu cho tab bar
  static const Color tabSelected = Color(0xFF6C63FF);
  static const Color tabUnselected = Color(0xFF2A2A2A);
  
  // Màu cho bottom navigation
  static const Color navBackground = Color(0xFF1A1A1A);
  static const Color navSelected = Color(0xFFD4AF37);
  static const Color navUnselected = Color(0xFF757575);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFB88746), Color(0xFFFDF5A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );
}

