import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/movie_model.dart';
import '../config/api_config.dart';

// Custom Exception cho Movie Service
class MovieServiceException implements Exception {
  final String message;
  final MovieErrorType type;
  
  MovieServiceException(this.message, this.type);
  
  @override
  String toString() => message;
}

// Loại lỗi
enum MovieErrorType {
  timeout,      // Quá thời gian chờ
  noInternet,   // Không có mạng
  serverError,  // Lỗi server
  unknown,      // Lỗi không xác định
}

// Service để gọi API Movies
class MovieService {
  // Timeout cho API calls (10 giây)
  static const Duration _timeout = Duration(seconds: 10);
  
  // Helper method để thực hiện GET request với timeout
  static Future<http.Response> _getWithTimeout(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      return response;
    } on TimeoutException {
      throw MovieServiceException(
        'Kết nối quá thời gian chờ. Vui lòng thử lại!',
        MovieErrorType.timeout,
      );
    } on SocketException {
      throw MovieServiceException(
        'Không có kết nối mạng. Vui lòng kiểm tra kết nối internet!',
        MovieErrorType.noInternet,
      );
    } catch (e) {
      throw MovieServiceException(
        'Không thể kết nối đến máy chủ!',
        MovieErrorType.unknown,
      );
    }
  }
  
  // Lấy tất cả phim
  static Future<List<Movie>> getAllMovies() async {
    final response = await _getWithTimeout('$BASE_URL/movies');
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Movie.fromJson(item)).toList();
    } else {
      throw MovieServiceException(
        'Lỗi máy chủ (${response.statusCode}). Vui lòng thử lại sau!',
        MovieErrorType.serverError,
      );
    }
  }
  
  // Lấy phim theo status: @param status: "nowShowing", "special", "comingSoon"
  static Future<List<Movie>> getMoviesByStatus(String status) async {
    final response = await _getWithTimeout('$BASE_URL/movies?status=$status');
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Movie.fromJson(item)).toList();
    } else {
      throw MovieServiceException(
        'Lỗi máy chủ (${response.statusCode})',
        MovieErrorType.serverError,
      );
    }
  }
  
  // Lấy phim phổ biến (rating >= 4.0)
  static Future<List<Movie>> getPopularMovies() async {
    final response = await _getWithTimeout('$BASE_URL/movies/popular');
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Movie.fromJson(item)).toList();
    } else {
      throw MovieServiceException(
        'Lỗi máy chủ (${response.statusCode})',
        MovieErrorType.serverError,
      );
    }
  }
  
  // Lấy phim đang chiếu
  static Future<List<Movie>> getNowShowingMovies() async {
    final response = await _getWithTimeout('$BASE_URL/movies/now-showing');
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Movie.fromJson(item)).toList();
    } else {
      throw MovieServiceException(
        'Lỗi máy chủ (${response.statusCode})',
        MovieErrorType.serverError,
      );
    }
  }
  
  // Lấy phim sắp chiếu
  static Future<List<Movie>> getComingSoonMovies() async {
    final response = await _getWithTimeout('$BASE_URL/movies/coming-soon');
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Movie.fromJson(item)).toList();
    } else {
      throw MovieServiceException(
        'Lỗi máy chủ (${response.statusCode})',
        MovieErrorType.serverError,
      );
    }
  }
  
  // Tìm kiếm phim theo từ khóa
  static Future<List<Movie>> searchMovies(String keyword) async {
    try {
      final response = await _getWithTimeout(
        '$BASE_URL/movies/search?q=${Uri.encodeComponent(keyword)}',
      );
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Movie.fromJson(item)).toList();
      } else {
        return []; // Search có thể return rỗng nếu lỗi
      }
    } catch (e) {
      print('Error searchMovies: $e');
      return []; // Search fail silently, trả về rỗng
    }
  }
  
  // Lấy chi tiết phim theo ID
  static Future<Movie?> getMovieById(int id) async {
    try {
      final response = await _getWithTimeout('$BASE_URL/movies/$id');
      
      if (response.statusCode == 200) {
        return Movie.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Error getMovieById: $e');
      return null;
    }
  }
}
