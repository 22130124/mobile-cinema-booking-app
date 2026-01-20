import 'movie_model.dart';

class MediaModel {
  String? mediaType;
  String? mediaURL;
}

class ActorModel {
  String? name;
  String? role;
  String? imageURL;
}

class MovieDetailsModel {
  String? movieId;
  String? title;
  String? description;
  int? duration;
  double? rating;
  String? releaseDate;
  String? ageRating;
  List<String>? genres;
  List<MediaModel>? media;
  List<ActorModel>? actors;

  MovieDetailsModel({
    this.movieId,
    this.title,
    this.description,
    this.duration,
    this.rating,
    this.releaseDate,
    this.ageRating,
    this.genres,
    this.media,
    this.actors,
  });

  factory MovieDetailsModel.fromMovie(Movie movie) {
    final media = <MediaModel>[];
    if (movie.posterUrl.isNotEmpty) {
      media.add(MediaModel()
        ..mediaType = 'Image'
        ..mediaURL = movie.posterUrl);
    }
    if (movie.backdropUrl.isNotEmpty && movie.backdropUrl != movie.posterUrl) {
      media.add(MediaModel()
        ..mediaType = 'Backdrop'
        ..mediaURL = movie.backdropUrl);
    }

    return MovieDetailsModel(
      movieId: movie.id.toString(),
      title: movie.title,
      description: movie.description,
      duration: movie.duration,
      rating: movie.rating,
      releaseDate: movie.releaseDate,
      ageRating: '',
      genres: movie.genre.isNotEmpty ? [movie.genre] : [],
      media: media.isEmpty ? null : media,
      actors: const [],
    );
  }

  factory MovieDetailsModel.fromApi(Map<String, dynamic> json) {
    final genreValue = (json['genre'] ?? '') as String;
    final genres = genreValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final posterUrl = (json['posterUrl'] ?? '') as String;
    final backdropUrl = (json['backdropUrl'] ?? '') as String;
    final media = <MediaModel>[];
    if (posterUrl.isNotEmpty) {
      media.add(MediaModel()
        ..mediaType = 'Image'
        ..mediaURL = posterUrl);
    }
    if (backdropUrl.isNotEmpty && backdropUrl != posterUrl) {
      media.add(MediaModel()
        ..mediaType = 'Backdrop'
        ..mediaURL = backdropUrl);
    }
    final trailerUrl = (json['trailerUrl'] ?? '') as String;
    final youtubeVideoId = (json['youtubeVideoId'] ?? '') as String;
    final videoSource = trailerUrl.isNotEmpty ? trailerUrl : youtubeVideoId;
    if (videoSource.isNotEmpty) {
      media.add(MediaModel()
        ..mediaType = 'Video'
        ..mediaURL = videoSource);
    }

    final castValue = (json['cast'] ?? '') as String;
    final actors = castValue
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .map((name) => ActorModel()
          ..name = name
          ..role = ''
          ..imageURL = '')
        .toList();

    return MovieDetailsModel(
      movieId: (json['id'] ?? json['movieId'])?.toString(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      releaseDate: json['releaseDate'] as String?,
      ageRating: json['ageRating'] as String?,
      genres: genres,
      media: media.isEmpty ? null : media,
      actors: actors,
    );
  }

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      movieId: json['movieId'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      rating: json['rating']?.toDouble(),
      releaseDate: json['releaseDate'],
      ageRating: json['ageRating'],
      genres: List<String>.from(json['genres'] ?? []),
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => MediaModel()
            ..mediaType = e['mediaType']
            ..mediaURL = e['mediaURL'])
          .toList(),
      actors: (json['actors'] as List<dynamic>?)
          ?.map((e) => ActorModel()
            ..name = e['name']
            ..role = e['role']
            ..imageURL = e['imageURL'])
          .toList(),
    );
  }
}
