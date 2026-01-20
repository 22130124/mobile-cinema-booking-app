class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String genre;
  final List<String>? genres;
  final List<int>? genreIds; // List for editing
  final double rating;
  final int duration;
  final String releaseDate;
  final String description;
  final MovieStatus status;
  final String? director;
  final String? cast;
  final String? ageRating;
  final bool isSpecial;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genre,
    this.genres,
    this.genreIds,
    required this.rating,
    required this.duration,
    required this.releaseDate,
    required this.description,
    required this.status,
    this.director,
    this.cast,
    this.ageRating,
    this.isSpecial = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String>? genresList;
    if (json['genres'] != null) {
      if (json['genres'] is List) {
        genresList = (json['genres'] as List).map((g) => g.toString()).toList();
      }
    }

    List<int>? genreIdsList;
    if (json['genreIds'] != null) {
      if (json['genreIds'] is List) {
        genreIdsList = (json['genreIds'] as List).map((id) => (id as num).toInt()).toList();
      }
    }

    MovieStatus status = MovieStatus.nowShowing;
    if (json['status'] != null) {
      final statusStr = json['status'].toString().toLowerCase();
      if (statusStr.contains('coming') || statusStr == 'comingsoon') {
        status = MovieStatus.comingSoon;
      } else if (statusStr.contains('ended') || statusStr == 'ended') {
        status = MovieStatus.ended;
      } else if (statusStr.contains('special') || statusStr == 'special') {
        status = MovieStatus.special;
      } else {
        status = MovieStatus.nowShowing;
      }
    }

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      backdropUrl: json['backdropUrl'] ?? '',
      genre: json['genre'] ?? (genresList?.isNotEmpty == true ? genresList!.first : ''),
      genres: genresList,
      genreIds: genreIdsList,
      rating: (json['rating'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      releaseDate: json['releaseDate'] ?? '',
      description: json['description'] ?? '',
      status: status,
      director: json['director'],
      cast: json['cast'],
      ageRating: json['ageRating'],
      isSpecial: json['isSpecial'] == true || json['isSpecial'] == 1,
    );
  }
}

enum MovieStatus { nowShowing, special, comingSoon, ended }
