class OrderResponse {
  final String id;
  final double? amount;
  final double? discountAmount;

  OrderResponse({required this.id, this.amount, this.discountAmount});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'],
      amount: _parseAmount(
        json['amount'] ??
            json['totalAmount'] ??
            json['totalPrice'] ??
            json['total'],
      ),
      discountAmount: _parseAmount(
        json['discountAmount'] ??
            json['discount'] ??
            json['totalDiscount'] ??
            json['promotionAmount'] ??
            json['promotion'],
      ),
    );
  }
}

double? _parseAmount(dynamic value) {
  if (value == null) return null;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
