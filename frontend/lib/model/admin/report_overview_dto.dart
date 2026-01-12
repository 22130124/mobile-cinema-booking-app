class ReportOverviewDto {
  final double totalRevenue;
  final int totalPaidOrders;
  final int totalTicketsSold;

  ReportOverviewDto({
    required this.totalRevenue,
    required this.totalPaidOrders,
    required this.totalTicketsSold,
  });

  factory ReportOverviewDto.fromJson(Map<String, dynamic> json) {
    return ReportOverviewDto(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalPaidOrders: (json['totalPaidOrders'] as num).toInt(),
      totalTicketsSold: (json['totalTicketsSold'] as num).toInt(),
    );
  }
}
