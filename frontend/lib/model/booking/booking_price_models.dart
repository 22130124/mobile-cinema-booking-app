class SeatTypeSummary {
  final String typeName;
  final int count;
  final int total;
  final int? unitPrice;

  const SeatTypeSummary({
    required this.typeName,
    required this.count,
    required this.total,
    this.unitPrice,
  });
}
