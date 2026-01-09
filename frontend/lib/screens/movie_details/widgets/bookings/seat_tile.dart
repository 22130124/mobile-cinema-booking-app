import 'package:flutter/material.dart';
import 'package:frontend/config/app_colors.dart';

class SeatTile extends StatelessWidget {
  final int status; // 0 available, 1 booked, 2 selected
  final String label;
  final double size;
  final double gap;
  final VoidCallback onTap;

  const SeatTile({
    Key? key,
    required this.status,
    required this.label,
    required this.size,
    required this.gap,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = status == 0
        ? AppColors.surface
        : status == 1
            ? AppColors.border
            : AppColors.accent;

    final iconColor = status == 0
        ? AppColors.textSecondary
        : status == 1
            ? AppColors.textHint
            : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: gap / 2),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: status == 0
                ? AppColors.border.withAlpha((0.2 * 255).round())
                : Colors.transparent,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.chair,
              size: size * 0.65,
              color: iconColor,
            ),
            Positioned(
              bottom: 4,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
