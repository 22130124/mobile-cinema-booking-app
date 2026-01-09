import 'package:flutter/foundation.dart';  // Thay vì dart:io
import 'package:flutter/material.dart';
import 'package:frontend/config/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrailerDialog extends StatefulWidget {
  final String videoId;
  const TrailerDialog({super.key, required this.videoId});

  @override
  State<TrailerDialog> createState() => _TrailerDialogState();
}

class _TrailerDialogState extends State<TrailerDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    if (!kIsWeb) {  // Sử dụng kIsWeb để kiểm tra platform web
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    _controller.loadRequest(Uri.parse('https://www.youtube.com/embed/${widget.videoId}?autoplay=1&rel=0'));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundLight,
      insetPadding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
