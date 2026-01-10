class MovieDetailDto {
  final int id;
  final String title;
  final String? description;
  final int duration;
  final String? releaseDate;
  final String? posterUrl;
  final String? backdropUrl;
  final num? rating;
  final String? director;
  final String? cast;
  final String? ageRating;
  final int? isSpecial;
  final int? status;
  final List<String> genres;

  // NEW
  final String? castImageUrls;

  MovieDetailDto({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    this.releaseDate,
    this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.director,
    this.cast,
    this.ageRating,
    this.isSpecial,
    this.status,
    required this.genres,
    this.castImageUrls,
  });

  factory MovieDetailDto.fromJson(Map<String, dynamic> json) {
    return MovieDetailDto(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      duration: (json['duration'] as num).toInt(),
      releaseDate: json['releaseDate'] as String?,
      posterUrl: json['posterUrl'] as String?,
      backdropUrl: json['backdropUrl'] as String?,
      rating: json['rating'] as num?,
      director: json['director'] as String?,
      cast: json['cast'] as String?,
      ageRating: json['ageRating'] as String?,
      isSpecial: (json['isSpecial'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      genres: (json['genres'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      castImageUrls: json['castImageUrls'] as String?,
    );
  }
}
