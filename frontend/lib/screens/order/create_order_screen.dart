import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/model/order/OrderRequest.dart';
import 'package:frontend/screens/payment/payment_success_screen.dart';
import 'package:frontend/service/order/order_service.dart';
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
      final request = OrderRequest(
        showTimeId: 1,
        userId: 2,
        seatIds: [3],
        userInfor: UserInforRequest(
          userEmail: "john.doe@example.com",
          userPhone: "1234567890",
          userName: "John Doe",
        ),
        seatTypeName: "Thường",
      );
      try {
        final response = await OrderService().createOrder(request);
        print("Order created successfully: $response.id");
        final paymentData = await OrderService().createPaymentUrl(response.id);
        final String paymentUrl = paymentData['paymentUrl']!;
        // if (await canLaunchUrl(Uri.parse(paymentUrl))) {
        //   await launchUrl(Uri.parse(paymentUrl));
        // } else {
        //   throw 'Could not launch $paymentUrl';
        // }
        await openPaymentUrl(context, paymentUrl);
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
            // ElevatedButton(
            //   onPressed: () {
            //     final fakeUri = Uri.parse(
            //       "cinemapp://payment-result?orderId=313f0191-9ec1-4585-b3f0-2ec939b55d03&status=success",
            //     );
            //     String? status = fakeUri.queryParameters['status'];
            //     String? orderId = fakeUri.queryParameters['orderId'];
            //     if (status == 'success' && orderId != null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               PaymentSuccessScreen(orderId: orderId),
            //         ),
            //       );
            //     } else {
            //       print("Thanh toán thất bại hoặc hủy bỏ");
            //     }
            //   },
            //   child: Text('Simulate Payment Success'),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> openPaymentUrl(BuildContext context, String paymentUrl) async {
    final url = paymentUrl.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid payment URL');
    }

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
      ..loadRequest(uri);

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
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: WebViewWidget(controller: controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
