import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          // Sau này sẽ thay bằng asset nội bộ
          Positioned.fill(
            child: Image.network(
              'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/bda5e6232709307.68a21568c92f9.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1A1A1A).withOpacity(0.8),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}