import 'package:flutter/material.dart';

class MoviePoster extends StatelessWidget {
  final String? imageUrl;
  const MoviePoster({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? '').trim();

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: url.isEmpty
          ? Container(
              color: Colors.white10,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white10,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
              ),
            ),
    );
  }
}
