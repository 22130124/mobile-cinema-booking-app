import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:frontend/model/order/OrderRequest.dart';
import 'package:frontend/screens/payment/payment_flow.dart';
import 'package:frontend/services/order/order_service.dart';
import 'package:frontend/storage/jwt_token_storage.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CreateOrderState();
  }
}

class _CreateOrderState extends State<CreateOrder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _handleCreateOrder() async {
      /*
      Create a sample order request
      Check duplicate SeatIDs in Database before creating order 
      */
      final userId = await JwtTokenStorage.getUserId();
      if (userId == null) {
        print("Vui lòng đăng nhập trước khi tạo đơn");
        return;
      }
      final request = OrderRequest(
        showTimeId: 2,
        userId: userId,
        seatIds: [5],
        userInfor: UserInforRequest(
          userEmail: "john.doe@example.com",
          userPhone: "1234567890",
          userName: "John Doe",
        ),
        seatTypeName: "Thường",
      );

      try {
        /*
        Call API to create order and get payment URL
        Then open payment URL in WebView or external browser
         */
        final response = await OrderService().createOrder(request);
        String? client;
        String? redirect;
        if (kIsWeb) {
          client = 'web';
          redirect = '${Uri.base.origin}/#/payment-result';
        }
        final paymentData = await OrderService().createPaymentUrl(
          response.id,
          client: client,
          redirect: redirect,
        );
        final String paymentUrl = paymentData['paymentUrl']!;
        // Chuyển chi tiết sang file payment/payment_flow.dart để gọn hơn 
        // và tái sử dụng logic trong booking_seat
        await openPaymentUrl(
          context,
          paymentUrl,
          response.id,
          onMessage: (message) => print(message),
        );
      } catch (e) {
        print("Failed to create order: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Create Order')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the Create Order Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleCreateOrder,
              child: Text('Create Order'),
            ),
          ],
        ),
      ),
    );
  }

}
