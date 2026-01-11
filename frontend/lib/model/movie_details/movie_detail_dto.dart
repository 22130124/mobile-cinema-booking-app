/// DTO tương ứng API backend: GET /api/movies/{id}
class MovieDetailDto {
  final int id;
  final String title;
  final String? description;
  final int duration;
  final String? releaseDate; // backend trả dạng yyyy-MM-dd (string)
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final String? director;
  final String? cast;
  final String? ageRating;
  final int? isSpecial;
  final int? status;
  final List<String> genres;

  // NEW: chuỗi URL ảnh diễn viên, phân tách bằng dấu phẩy, cùng thứ tự với `cast`
  final String? castImageUrls;

  MovieDetailDto({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.releaseDate,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.director,
    required this.cast,
    required this.ageRating,
    required this.isSpecial,
    required this.status,
    required this.genres,
    required this.castImageUrls,
  });

  /// Logic: parse JSON trả về từ Spring Boot DTO
  factory MovieDetailDto.fromJson(Map<String, dynamic> json) {
    return MovieDetailDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      releaseDate: json['releaseDate'] as String?,
      posterUrl: json['posterUrl'] as String?,
      backdropUrl: json['backdropUrl'] as String?,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      director: json['director'] as String?,
      cast: json['cast'] as String?,
      ageRating: json['ageRating'] as String?,
      isSpecial: (json['isSpecial'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
      castImageUrls: json['castImageUrls'] as String?,
    );
  }
}
