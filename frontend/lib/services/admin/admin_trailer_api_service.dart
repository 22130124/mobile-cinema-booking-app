import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../model/admin/trailer_admin_dto.dart';
import '../../storage/jwt_token_storage.dart';

class AdminTrailerApiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<TrailerAdminDto>> list({int? movieId}) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Chưa có JWT';

    final uri = Uri.parse('$baseUrl/auth/admin/trailers').replace(
      queryParameters: {
        if (movieId != null) 'movieId': movieId.toString(),
      },
    );

    final resp = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode != 200) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }

    final raw = jsonDecode(resp.body);
    if (raw is! List) throw 'Response không phải List';
    return raw
        .cast<Map<String, dynamic>>()
        .map(TrailerAdminDto.fromJson)
        .toList();
  }

  Future<TrailerAdminDto> create({
    required int movieId,
    required String youtubeVideoId,
    required String title,
  }) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Chưa có JWT';

    final url = Uri.parse('$baseUrl/auth/admin/trailers');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'movieId': movieId,
        'youtubeVideoId': youtubeVideoId,
        'title': title,
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
    return TrailerAdminDto.fromJson(jsonDecode(resp.body));
  }

  Future<TrailerAdminDto> update({
    required int id,
    required String youtubeVideoId,
    required String title,
  }) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Chưa có JWT';

    final url = Uri.parse('$baseUrl/auth/admin/trailers/$id');
    final resp = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'youtubeVideoId': youtubeVideoId,
        'title': title,
      }),
    );

    if (resp.statusCode != 200) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
    return TrailerAdminDto.fromJson(jsonDecode(resp.body));
  }

  Future<void> delete(int id) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Chưa có JWT';

    final url = Uri.parse('$baseUrl/auth/admin/trailers/$id');
    final resp = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
  }
}
