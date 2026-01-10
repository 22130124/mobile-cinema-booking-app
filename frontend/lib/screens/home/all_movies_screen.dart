import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../model/movie_model.dart';
import '../../widgets/home/movie_card.dart';

/// Màn hình hiển thị tất cả phim, Dùng cho nút "Xem tất cả" ở các section trong HomeScreen
class AllMoviesScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final IconData icon;
  final Color iconColor;

  const AllMoviesScreen({
    super.key,
    required this.title,
    required this.movies,
    this.icon = Icons.movie,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: movies.isEmpty
          ? _buildEmptyState()
          : _buildMovieGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter,
            size: 80,
            color: AppColors.surface,
          ),
          SizedBox(height: 16),
          Text(
            'Không có phim nào',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return _buildGridMovieCard(movies[index]);
        },
      ),
    );
  }

  Widget _buildGridMovieCard(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: Icon(Icons.movie, color: AppColors.textHint, size: 40),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildStatusBadge(movie.status),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        
        // Title
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6),
        
        // Rating & Duration
        Row(
          children: [
            Icon(Icons.star, color: AppColors.accent, size: 14),
            SizedBox(width: 4),
            Text(
              movie.rating.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.access_time, color: AppColors.textSecondary, size: 12),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                '${movie.duration} phút',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(MovieStatus status) {
    String text;
    Color color;

    switch (status) {
      case MovieStatus.nowShowing:
        text = 'Đang chiếu';
        color = AppColors.chipNowShowing;
        break;
      case MovieStatus.special:
        text = 'Đặc biệt';
        color = AppColors.chipSpecial;
        break;
      case MovieStatus.comingSoon:
        text = 'Sắp chiếu';
        color = AppColors.chipComingSoon;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


