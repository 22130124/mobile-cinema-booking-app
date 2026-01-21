import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../storage/jwt_token_storage.dart';
import '../../model/movie_model.dart';

/// Service để gọi API quản lý phim cho Admin
class AdminMovieApiService {
  final String _baseUrl = BASE_URL.replaceAll('/api', '');

  /// Lấy JWT token từ storage
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await JwtTokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Lấy all phim
  Future<List<Movie>> getAllMovies({MovieStatus? status}) async {
    try {
      String url = '$_baseUrl/api/movies';
      if (status != null) {
        final statusValue = status.name.toUpperCase();
        url += '?status=$statusValue';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách phim: $e');
    }
  }

  /// Tìm kiếm
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/movies/search?q=$query'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tìm kiếm phim: $e');
    }
  }

  /// Lấy chi tiết phim
  Future<Movie> getMovieById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/movies/$id'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return Movie.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy phim');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải thông tin phim: $e');
    }
  }

  /// Tạo phim mới
  Future<Movie> createMovie(MovieRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/movies'),
        headers: await _getAuthHeaders(),
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Movie.fromJson(json.decode(response.body));
      } else {
        final error = _parseError(response);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Không thể tạo phim: $e');
    }
  }

  /// Cập nhật phim
  Future<Movie> updateMovie(int id, MovieRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/admin/movies/$id'),
        headers: await _getAuthHeaders(),
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return Movie.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy phim');
      } else {
        final error = _parseError(response);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Không thể cập nhật phim: $e');
    }
  }

  /// Xóa phim
  Future<void> deleteMovie(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/admin/movies/$id'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Không tìm thấy phim');
        }
        final error = _parseError(response);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Không thể xóa phim: $e');
    }
  }

  /// Lấy danh sách thể loại
  Future<List<Genre>> getAllGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/genres'),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Genre.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách thể loại: $e');
    }
  }

  /// Tạo thể loại mới
  Future<Genre> createGenre(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/genres'),
        headers: await _getAuthHeaders(),
        body: json.encode({'name': name}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Genre.fromJson(json.decode(response.body));
      } else {
        final error = _parseError(response);
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Không thể tạo thể loại: $e');
    }
  }

  String _parseError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Lỗi không xác định';
    } catch (_) {
      return 'Lỗi server: ${response.statusCode}';
    }
  }
}

/// DTO cho request tạo/cập nhật phim
class MovieRequest {
  final String title;
  final String? description;
  final int duration;
  final String releaseDate;
  final String posterUrl;
  final String? backdropUrl;
  final double? rating;
  final String? director;
  final String? cast;
  final String? ageRating;
  final bool isSpecial;
  final String status;
  final List<int> genreIds;

  MovieRequest({
    required this.title,
    this.description,
    required this.duration,
    required this.releaseDate,
    required this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.director,
    this.cast,
    this.ageRating,
    this.isSpecial = false,
    required this.status,
    required this.genreIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'releaseDate': releaseDate,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'rating': rating,
      'director': director,
      'cast': cast,
      'ageRating': ageRating,
      'isSpecial': isSpecial,
      'status': status,
      'genreIds': genreIds,
    };
  }
}

/// Model thể loại
class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
