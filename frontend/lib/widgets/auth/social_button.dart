import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconUrl;
  final VoidCallback? onTapSync;
  final Future<void> Function()? onTapAsync;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.text,
    required this.iconUrl,
    this.onTapSync,
    this.onTapAsync,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading
          ? null
          : onTapAsync != null
          ? () => onTapAsync!()
          : onTapSync,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon hoặc Loading
            SizedBox(
              width: 24,
              height: 24,
              child: isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    )
                  : Image.network(
                      iconUrl,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
            ),
            const SizedBox(width: 12),

            // Text luôn hiển thị
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
