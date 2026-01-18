import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../model/admin/daily_revenue_point_dto.dart';

class RevenueLineChart extends StatelessWidget {
  final List<DailyRevenuePointDto> points;
  const RevenueLineChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu chart', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    // x = index (0..n-1), y = revenue
    final spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < points.length; i++) {
      final y = points[i].revenue;
      spots.add(FlSpot(i.toDouble(), y));
      if (y > maxY) maxY = y;
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY * 1.2,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 46),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: points.length > 10 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                final d = points[i].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${d.month}/${d.day}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: AppColors.accent,
            dotData: FlDotData(show: points.length <= 14),
            belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.12)),
          )
        ],
      ),
    );
  }
}
