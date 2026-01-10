/// DTO tương ứng API backend: GET /api/movies/{id}/trailers
class TrailerDto {
  final int id;
  final int movieId;
  final String youtubeVideoId;
  final String? title;

  TrailerDto({
    required this.id,
    required this.movieId,
    required this.youtubeVideoId,
    required this.title,
  });

  factory TrailerDto.fromJson(Map<String, dynamic> json) {
    return TrailerDto(
      id: json['id'],
      movieId: json['movieId'],
      youtubeVideoId: json['youtubeVideoId'],
      title: json['title'],
    );
  }

  /// Logic: build URL dạng watch để youtube_player có thể convertUrlToId(...)
  String get youtubeWatchUrl => 'https://www.youtube.com/watch?v=$youtubeVideoId';
}
