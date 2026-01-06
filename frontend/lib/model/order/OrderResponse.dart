class OrderResponse {
  final String id;

  OrderResponse({required this.id});

factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id']
    );
  }
}