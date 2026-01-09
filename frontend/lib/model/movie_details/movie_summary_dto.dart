/// DTO tương ứng API backend: GET /api/movies/{id}/related
class MovieSummaryDto {
  final int id;
  final String title;
  final String? posterUrl;
  final double rating;
  final String? releaseDate;
  final String? ageRating;
  final int? status;

  MovieSummaryDto({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.releaseDate,
    required this.ageRating,
    required this.status,
  });

  factory MovieSummaryDto.fromJson(Map<String, dynamic> json) {
    return MovieSummaryDto(
      id: json['id'],
      title: json['title'],
      posterUrl: json['posterUrl'],
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      releaseDate: json['releaseDate'],
      ageRating: json['ageRating'],
      status: json['status'],
    );
  }
}
