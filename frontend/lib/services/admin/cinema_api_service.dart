import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../model/admin/cinema_dto.dart';

class CinemaApiService {
  final String baseUrl = BASE_URL;

  Future<List<CinemaDto>> list() async {
    final url = Uri.parse('$baseUrl/cinemas');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }

    final raw = jsonDecode(resp.body);
    if (raw is! List) throw 'Response không phải List';

    return raw.cast<Map<String, dynamic>>().map(CinemaDto.fromJson).toList();
  }
}
