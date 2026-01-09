import 'package:flutter/material.dart';
import 'package:frontend/model/movie_details.dart';

class MoviePoster extends StatelessWidget {
  final MovieDetailsModel movie;
  const MoviePoster({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    String? posterUrl;
    if (movie.media != null && movie.media!.isNotEmpty) {
      posterUrl = movie.media!.firstWhere(
        (m) => m.mediaType == 'Image',
        orElse: () => movie.media!.first,
      ).mediaURL;
    }

    return Container(
      height: 300,  // Giảm height để fit hơn, tránh overflow
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(posterUrl ?? 'https://via.placeholder.com/400x600?text=No+Image'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
