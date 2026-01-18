class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String genre;
  final double rating;
  final int duration;
  final String releaseDate;
  final String description;
  final MovieStatus status;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genre,
    required this.rating,
    required this.duration,
    required this.releaseDate,
    required this.description,
    required this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      backdropUrl: json['backdropUrl'] ?? '',
      genre: json['genre'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      releaseDate: json['releaseDate'] ?? '',
      description: json['description'] ?? '',
      status: MovieStatus.values.firstWhere(
            (e) => e.toString() == 'MovieStatus.${json['status']}',
        orElse: () => MovieStatus.nowShowing,
      ),
    );
  }
}

enum MovieStatus { nowShowing, special, comingSoon }

