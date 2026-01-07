import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/model/order/OrderRequest.dart';
import 'package:frontend/screens/payment/payment_success_screen.dart';
import 'package:frontend/services/order/order_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
      final request = OrderRequest(
        showTimeId: 2,
        userId: 2,
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
        final paymentData = await OrderService().createPaymentUrl(response.id);
        final String paymentUrl = paymentData['paymentUrl']!;
        await openPaymentUrl(context, paymentUrl, response.id);
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

  Future<void> openPaymentUrl(
    BuildContext context,
    String paymentUrl,
    String orderId,
  ) async {
    final url = paymentUrl.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid payment URL');
    }

    bool paymentCompleted = false;

    // Try external browser first
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest req) async {
            final url = req.url;
            if (url.startsWith('cinemapp://')) {
              Navigator.of(context).pop();
              try {
                final uri = Uri.parse(url);
                final orderId =
                    uri.queryParameters['orderId'] ??
                    uri.queryParameters['vnp_TxnRef'];
                final status =
                    uri.queryParameters['status'] ??
                    (uri.queryParameters['vnp_ResponseCode'] == '00'
                        ? 'success'
                        : 'fail');
                if (status == 'success' && orderId != null) {
                  // await OrderService().handleVNPayReturn();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentSuccessScreen(orderId: orderId),
                    ),
                  );
                }
              } catch (_) {}
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(uri, headers: {'ngrok-skip-browser-warning': 'true'});

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.85,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Payment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        await OrderService().deleteSeatHoldByUser(orderId);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
          ),
        );
      },
    );
  }
}
