class DailyRevenuePointDto {
  final DateTime date;
  final double revenue;
  final int paidOrders;
  final int ticketsSold;

  DailyRevenuePointDto({
    required this.date,
    required this.revenue,
    required this.paidOrders,
    required this.ticketsSold,
  });

  factory DailyRevenuePointDto.fromJson(Map<String, dynamic> json) {
    // json['date'] dạng yyyy-MM-dd
    final date = DateTime.parse('${json['date']}T00:00:00');
    return DailyRevenuePointDto(
      date: date,
      revenue: (json['revenue'] as num).toDouble(),
      paidOrders: (json['paidOrders'] as num).toInt(),
      ticketsSold: (json['ticketsSold'] as num).toInt(),
    );
  }
}
