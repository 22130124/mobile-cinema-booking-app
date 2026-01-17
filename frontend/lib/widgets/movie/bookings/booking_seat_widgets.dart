import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import 'date_time_option.dart';

class BookingSeatLegend extends StatelessWidget {
  const BookingSeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendItem(color: AppColors.surface, label: 'Ghế trống'),
        SizedBox(width: 16),
        _LegendItem(color: AppColors.border, label: 'Ghế được đặt'),
        SizedBox(width: 16),
        _LegendItem(color: AppColors.accent, label: 'Ghế đã chọn'),
      ],
    );
  }
}

class SelectedSeatsSummary extends StatelessWidget {
  final List<String> seatLabels;

  const SelectedSeatsSummary({super.key, required this.seatLabels});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withAlpha((0.25 * 255).round()),
        ),
      ),
      child: Text(
        'Ghế đã chọn: ${seatLabels.join(', ')}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class TotalAndBuyBar extends StatelessWidget {
  final String formattedTotal;
  final bool isEnabled;
  final VoidCallback onPressed;

  const TotalAndBuyBar({
    super.key,
    required this.formattedTotal,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thành tiền',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$formattedTotal VND',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textHint,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Mua Vé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BookingDateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;

  const BookingDateSelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Chọn Ngày',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates
                .map(
                  (date) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 80,
                      child: DateOption(
                        day: date.day,
                        month: date.month,
                        dayName: _dayLabel(date),
                        isSelected: selectedDate != null &&
                            _isSameDate(selectedDate!, date),
                        onTap: () => onSelect(date),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (_isSameDate(date, now)) return "Hôm nay";
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'C.Nhật';
      default:
        return '';
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isAvailable = color == AppColors.surface;
    final iconColor = color == AppColors.accent
        ? Colors.black
        : color == AppColors.border
            ? AppColors.textHint
            : AppColors.textSecondary;
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isAvailable
                  ? AppColors.border.withAlpha((0.25 * 255).round())
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            Icons.chair,
            size: 12,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
