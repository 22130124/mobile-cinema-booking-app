import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconUrl; // Đường dẫn ảnh logo
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
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.network(
              iconUrl,
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(width: 12),
            // Text
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