class TrailerAdminDto {
  final int id;
  final int movieId;
  final String youtubeVideoId;
  final String title;

  TrailerAdminDto({
    required this.id,
    required this.movieId,
    required this.youtubeVideoId,
    required this.title,
  });

  factory TrailerAdminDto.fromJson(Map<String, dynamic> json) {
    return TrailerAdminDto(
      id: (json['id'] as num).toInt(),
      movieId: (json['movieId'] as num).toInt(),
      youtubeVideoId: (json['youtubeVideoId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
    );
  }
}
