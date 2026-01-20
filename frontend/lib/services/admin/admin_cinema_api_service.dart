import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../model/admin/cinema_dto.dart';
import '../../storage/jwt_token_storage.dart';

class AdminCinemaApiService {
  final String baseUrl = getAuthBaseUrl();

  Future<List<CinemaDto>> list() async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Missing JWT';

    final uri = Uri.parse('$baseUrl/auth/admin/cinemas');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 200) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }

    final raw = jsonDecode(resp.body);
    if (raw is! List) throw 'Response is not a List';
    return raw.cast<Map<String, dynamic>>().map(CinemaDto.fromJson).toList();
  }

  Future<CinemaDto> create({
    required String name,
    required String address,
    required String city,
    required String imageUrl,
    required bool isActive,
  }) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Missing JWT';

    final uri = Uri.parse('$baseUrl/auth/admin/cinemas');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
        'city': city,
        'imageUrl': imageUrl,
        'isActive': isActive,
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
    return CinemaDto.fromJson(jsonDecode(resp.body));
  }

  Future<CinemaDto> update({
    required int id,
    required String name,
    required String address,
    required String city,
    required String imageUrl,
    required bool isActive,
  }) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Missing JWT';

    final uri = Uri.parse('$baseUrl/auth/admin/cinemas/$id');
    final resp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
        'city': city,
        'imageUrl': imageUrl,
        'isActive': isActive,
      }),
    );

    if (resp.statusCode != 200) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
    return CinemaDto.fromJson(jsonDecode(resp.body));
  }

  Future<void> deactivate(int id) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.isEmpty) throw 'Missing JWT';

    final uri = Uri.parse('$baseUrl/auth/admin/cinemas/$id');
    final resp = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
  }
}
