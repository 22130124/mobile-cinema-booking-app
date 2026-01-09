import 'package:flutter/material.dart';
import 'package:frontend/screens/movie_details/booking_seat_sheet.dart';
import '../../config/app_colors.dart';
import '../../model/movie_details.dart';
import '../../services/order/movie_details_service.dart';
import '../../storage/jwt_token_storage.dart';
import 'widgets/movie_poster.dart';
import 'widgets/movie_info.dart';
import 'widgets/cast_list.dart';

class MovieDetailScreen extends StatefulWidget {
  final String? movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  factory MovieDetailScreen.fromModel({required MovieDetailsModel movie}) {
    return MovieDetailScreen(movieId: movie.movieId);
  }

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late final Future<MovieDetailsModel> _movieFuture;
  int? _movieId;

  @override
  void initState() {
    super.initState();
    _movieId = int.tryParse(widget.movieId ?? '');
    if (_movieId == null) {
      _movieFuture = Future.error('Invalid movie id');
    } else {
      _movieFuture = MovieDetailsService().getMovieDetails(_movieId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MovieDetailsModel>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text(
                'Failed to load movie details',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final movie = snapshot.data!;
        final movieId = _movieId ?? int.tryParse(movie.movieId ?? '') ?? 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoviePoster(movie: movie),
                MovieInfo(movie: movie),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    movie.description ?? '',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Xem thêm',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
                CastList(actors: movie.actors ?? []),
                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
            child: ElevatedButton(
              onPressed: movieId == 0
                  ? null
                  : () async {
                      final userId = await JwtTokenStorage.getUserId();
                      if (!mounted) return;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng đăng nhập để đặt vé'),
                          ),
                        );
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BookingSeatSheet(
                          movieId: movieId,
                          userId: userId,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.textHint,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Đặt ghế',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
