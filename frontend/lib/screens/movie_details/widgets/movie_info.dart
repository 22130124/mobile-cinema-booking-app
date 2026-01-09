import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/config/app_colors.dart';
import 'package:frontend/model/movie_details.dart';
import './trailer_dialog.dart'; // Để mở trailer
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieInfo extends StatelessWidget {
  final MovieDetailsModel movie;
  const MovieInfo({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final mediaItem = movie.media?.firstWhere(
      (m) => (m.mediaType ?? '').toLowerCase() == 'video',
      orElse: () => MediaModel(),
    );
    final rawVideoUrl = mediaItem?.mediaURL ?? '';
    final videoUrl = rawVideoUrl.isNotEmpty
        ? (rawVideoUrl.startsWith('http')
            ? rawVideoUrl
            : 'https://www.youtube.com/watch?v=$rawVideoUrl')
        : '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${movie.duration ?? 0} phút',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title ?? 'Không có tiêu đề',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: movie.genres?.map((genre) => Text(
                  '$genre • ',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                )).toList() ??
                [],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.star, color: AppColors.accent, size: 16),
              const SizedBox(width: 4),
              Text(
                '${movie.rating ?? 0.0}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(width: 16),
              Text(
                movie.releaseDate ?? '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(width: 16),
              Text(
                movie.ageRating ?? '',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (videoUrl.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    final String? videoId = YoutubePlayer.convertUrlToId(videoUrl);
                    if (videoId != null) {
                      showDialog(
                        context: context,
                        builder: (_) => TrailerDialog(videoId: videoId),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Trailer'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
