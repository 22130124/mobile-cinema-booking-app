import 'dart:convert';
import 'package:frontend/model/order/Order.dart';
import 'package:frontend/model/order/OrderRequest.dart';
import 'package:frontend/model/order/OrderResponse.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class OrderService {
  Future<List<OrderHistoryItem>> getListOrder(int userId) async {
    userId = 2;
    final response = await http.get(
      Uri.parse('$BASE_URL/booking/getListBooking/$userId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      List<OrderHistoryItem> bookings = body
          .map((dynamic item) => OrderHistoryItem.fromJson(item))
          .toList();

      return bookings;
    } else {
      throw Exception('Lấy danh sách ve thất bại');
    }
  }

  Future<OrderDetail> getTicketById(String id) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/booking/getOrderById/$id'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return OrderDetail.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('404 Not Found');
    } else {
      throw Exception('Lấy danh sách ve thất bại');
    }
  }

  Future<OrderResponse> createOrder(OrderRequest postOrder) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/booking/createOrder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postOrder.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        return OrderResponse.fromJson(jsonResponse);
      } else {
        throw Exception("Tạo đơn hàng thất bại: ${response.body}");
      }
    } catch (e) {
      throw Exception("Lỗi khi tạo đơn hàng: $e");
    }
  }

  Future<Map<String, String>> createPaymentUrl(String bookingId) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/payment/createPaymentUrl/$bookingId'),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return {'paymentUrl': jsonResponse['paymentUrl']};
    } else {
      throw Exception('Tạo URL thanh toán thất bại');
    }
  }

  Future<void> deleteSeatHoldByUser(String orderId) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL/booking/deleteSeatHoldByUser/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Yêu cầu thực hiện thành công");
    } else {
      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    }
  }
}
