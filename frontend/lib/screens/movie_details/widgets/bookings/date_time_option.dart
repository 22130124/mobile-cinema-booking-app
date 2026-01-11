import 'package:flutter/material.dart';
import 'package:frontend/config/app_colors.dart';

class DateOption extends StatelessWidget {
  final int day;
  final int month;
  final String dayName;
  final bool isSelected;
  final VoidCallback onTap;

  const DateOption({
    Key? key,
    required this.day,
    required this.month,
    required this.dayName,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              dateLabel,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeOption extends StatelessWidget {
  final String time;
  final String? subtitle;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const TimeOption({
    Key? key,
    required this.time,
    this.subtitle,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle ?? '';
    final selected = isSelected && !isDisabled;
    final borderColor = selected ? AppColors.accent : AppColors.border;
    final backgroundColor = selected
        ? AppColors.accent.withAlpha((0.18 * 255).round())
        : AppColors.surface;
    final timeColor = selected ? AppColors.accent : AppColors.textPrimary;
    final subtitleColor = selected ? AppColors.accent : AppColors.textHint;
    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: timeColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitleText.isNotEmpty)
                const SizedBox(height: 4),
              if (subtitleText.isNotEmpty)
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
