import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../model/movie_details/movie_detail_dto.dart';
import '../../model/movie_details/movie_summary_dto.dart';
import '../../model/movie_details/trailer_dto.dart';

class MovieApiService {
  final String baseUrl = ApiConfig.baseUrl;

  /// Logic: GET /api/movies/{id} => lấy chi tiết phim từ DB
  Future<MovieDetailDto> getMovieDetail(int movieId) async {
    final url = Uri.parse('$baseUrl/api/movies/$movieId');
    final resp = await http.get(url);

    if (resp.statusCode != 200) {
      throw 'Get movie detail failed: ${resp.statusCode} ${resp.body}';
    }

    return MovieDetailDto.fromJson(jsonDecode(resp.body));
  }

  /// Logic: GET /api/movies/{id}/trailers => trailer theo movie_id
  Future<List<TrailerDto>> getTrailers(int movieId) async {
    final url = Uri.parse('$baseUrl/api/movies/$movieId/trailers');
    final resp = await http.get(url);

    if (resp.statusCode != 200) {
      throw 'Get trailers failed: ${resp.statusCode} ${resp.body}';
    }

    final list = jsonDecode(resp.body) as List;
    return list.map((e) => TrailerDto.fromJson(e)).toList();
  }

  /// Logic: GET /api/movies/{id}/related?limit=10 => phim liên quan cùng thể loại
  Future<List<MovieSummaryDto>> getRelatedMovies(int movieId, {int limit = 10}) async {
    final url = Uri.parse('$baseUrl/api/movies/$movieId/related?limit=$limit');
    final resp = await http.get(url);

    if (resp.statusCode != 200) {
      throw 'Get related movies failed: ${resp.statusCode} ${resp.body}';
    }

    final list = jsonDecode(resp.body) as List;
    return list.map((e) => MovieSummaryDto.fromJson(e)).toList();
  }
}
