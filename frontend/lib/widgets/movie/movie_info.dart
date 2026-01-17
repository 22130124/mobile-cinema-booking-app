import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../config/app_colors.dart';
import '../../model/movie_details/movie_detail_dto.dart';
import 'trailer_dialog.dart';

class MovieInfo extends StatelessWidget {
  final MovieDetailDto detail;
  final String? trailerUrl;

  const MovieInfo({
    super.key,
    required this.detail,
    this.trailerUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${detail.duration} phút',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            detail.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.genres
                .map((g) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        g,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.star, color: AppColors.accent, size: 16),
              const SizedBox(width: 6),
              Text('${detail.rating}',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              const SizedBox(width: 16),
              Text(detail.releaseDate ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(width: 16),
              Text(
                detail.ageRating ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (trailerUrl != null && trailerUrl!.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    final String? videoId = YoutubePlayer.convertUrlToId(trailerUrl!);
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
