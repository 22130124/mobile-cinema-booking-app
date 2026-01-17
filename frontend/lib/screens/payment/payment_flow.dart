import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/order/order_service.dart';
import 'payment_success_screen.dart';

class PaymentDialogStyle {
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final Color? closeIconColor;

  const PaymentDialogStyle({
    this.backgroundColor,
    this.titleStyle,
    this.closeIconColor,
  });
}

Future<bool> openPaymentUrl(
  BuildContext context,
  String paymentUrl,
  String orderId, {
  void Function(String message)? onMessage,
  PaymentDialogStyle? dialogStyle,
  bool Function()? canNavigate,
  ValueChanged<String>? onSuccess,
}) async {
  final url = paymentUrl.replaceAll(RegExp(r'\s+'), '');
  final uri = Uri.tryParse(url);
  if (uri == null) {
    _notify(onMessage, 'Invalid payment URL');
    return false;
  }

  bool paymentCompleted = false;
  String? successOrderId;

  if (kIsWeb) {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return false;
      }
    } catch (_) {}
    _notify(onMessage, 'Khong the mo trang thanh toan tren web');
    return false;
  }

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
              final resultOrderId =
                  uri.queryParameters['orderId'] ??
                  uri.queryParameters['vnp_TxnRef'];
              final status = uri.queryParameters['status'] ??
                  (uri.queryParameters['vnp_ResponseCode'] == '00'
                      ? 'success'
                      : 'fail');
              if (status == 'success' && resultOrderId != null) {
                paymentCompleted = true;
                successOrderId = resultOrderId;
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
        backgroundColor: dialogStyle?.backgroundColor,
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.85,
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'Payment',
                    style:
                        dialogStyle?.titleStyle ??
                        const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: dialogStyle?.closeIconColor,
                    ),
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

  if (paymentCompleted) {
    if (canNavigate != null && !canNavigate()) {
      return paymentCompleted;
    }
    final resolvedOrderId = successOrderId ?? orderId;
    if (onSuccess != null) {
      onSuccess(resolvedOrderId);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(orderId: resolvedOrderId),
        ),
      );
    }
  }

  return paymentCompleted;
}

void _notify(void Function(String message)? onMessage, String message) {
  if (onMessage != null) {
    onMessage(message);
  } else {
    debugPrint(message);
  }
}
