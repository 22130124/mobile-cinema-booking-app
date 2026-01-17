import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

import '../../services/movie_details/movie_api_service.dart';
import '../../model/movie_details/movie_detail_dto.dart';
import '../../model/movie_details/trailer_dto.dart';
import '../../model/movie_details/movie_summary_dto.dart';
import '../../storage/jwt_token_storage.dart';

import 'booking_seat_sheet.dart';
import '../../widgets/movie/movie_poster.dart';
import '../../widgets/movie/movie_info.dart';
import '../../widgets/movie/cast_list.dart';
import '../../widgets/movie/detail_movie_skeleton.dart';
import '../../widgets/movie/related_movies_list.dart';

class MovieDetailScreen extends StatefulWidget {
  final String? movieId;

  const MovieDetailScreen({super.key, this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _api = MovieApiService();

  MovieDetailDto? detail; // null => loading
  List<TrailerDto> trailers = const [];
  List<MovieSummaryDto> related = const [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final id = int.tryParse(widget.movieId ?? '');
    if (id == null || id <= 0) {
      setState(() {
        errorMessage = 'movieId không hợp lệ';
      });
      return;
    }

    _loadFromApi(id);
  }

  Future<void> _loadFromApi(int movieId) async {
    setState(() {
      detail = null;
      trailers = const [];
      related = const [];
      errorMessage = null;
    });

    try {
      final d = await _api.getMovieDetail(movieId);
      final t = await _api.getTrailers(movieId);
      final r = await _api.getRelatedMovies(movieId, limit: 10);

      if (!mounted) return;

      setState(() {
        detail = d;
        trailers = t;
        related = r;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        detail = null;
      });
    }
  }

  List<ActorVm> _mapActors(MovieDetailDto d) {
    final actorNames = (d.cast ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final imageUrls = (d.castImageUrls ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return List.generate(actorNames.length, (i) {
      final url = (i < imageUrls.length) ? imageUrls[i] : null;
      return ActorVm(
        name: actorNames[i],
        role: '',
        imageUrl: url,
      );
    });
  }

  String? _pickHeroImage(MovieDetailDto d) {
    final backdrop = (d.backdropUrl ?? '').trim();
    if (backdrop.isNotEmpty) return backdrop;

    final poster = (d.posterUrl ?? '').trim();
    if (poster.isNotEmpty) return poster;

    return null;
  }

  String? _firstTrailerUrl(List<TrailerDto> t) {
    if (t.isEmpty) return null;

    // Nếu TrailerDto của bạn có field youtubeVideoId:
    final id = (t.first.youtubeVideoId ?? '').trim();
    if (id.isEmpty) return null;

    return 'https://www.youtube.com/watch?v=$id';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openBookingSheet() async {
    final movieId = detail?.id ?? 0;
    if (movieId <= 0) {
      _showSnack('Invalid movie id.');
      return;
    }

    final userId = await JwtTokenStorage.getUserId();
    if (!mounted) return;
    if (userId == null) {
      _showSnack('Please log in to book seats.');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingSeatSheet(movieId: movieId, userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.movieId ?? '') ?? 0;

    if (detail == null && errorMessage == null) {
      return const DetailMovieSkeleton();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Lỗi tải dữ liệu: $errorMessage',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),

            if (detail != null) ...[
              MoviePoster(imageUrl: _pickHeroImage(detail!)),
              MovieInfo(
                detail: detail!,
                trailerUrl: _firstTrailerUrl(trailers),
              ),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nội dung phim',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  (detail!.description ?? '').trim(),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Diễn viên',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CastList(actors: _mapActors(detail!)),

              RelatedMoviesList(
                movies: related,
                onTap: (m) {
                  final nextId = m.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movieId: nextId.toString()),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ] else ...[
              // detail == null nhưng có errorMessage => show placeholder
              const SizedBox(height: 180),
              Center(
                child: Text(
                  'Không có dữ liệu phim.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 180),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
        child: ElevatedButton(
          onPressed: detail == null ? null : _openBookingSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.surface,
            disabledForegroundColor: AppColors.textHint,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text(
            'Đặt Ghế',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
