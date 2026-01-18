import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../model/admin/report_overview_dto.dart';
import '../../model/admin/daily_revenue_point_dto.dart';
import '../../storage/jwt_token_storage.dart';

class ReportsApiService {
  final String baseUrl = getAuthBaseUrl();

  String _fmt(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}T${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Bearer token nằm ở header Authorization [web:1587]
      };

  Future<String> _requireToken(String tag) async {
    final token = await JwtTokenStorage.getToken();
    if (token == null || token.trim().isEmpty) {
      throw 'Chưa có JWT ($tag)';
    }
    return token.trim();
  }

  Never _throwHttp(http.Response resp, Uri uri) {
    // Ném lỗi rõ ràng để bạn nhìn ra 401/403/500 ngay trên UI
    final body = resp.body.isEmpty ? '(empty body)' : resp.body;
    throw 'HTTP ${resp.statusCode} ${uri.path}: $body';
  }

  Future<ReportOverviewDto> getOverview({
    required DateTime from,
    required DateTime to,
    int? cinemaId,
  }) async {
    final token = await _requireToken('overview');

    final uri = Uri.parse('$baseUrl/auth/admin/reports/overview').replace(
      queryParameters: {
        'from': _fmt(from),
        'to': _fmt(to),
        if (cinemaId != null) 'cinemaId': cinemaId.toString(),
      },
    );

    if (kDebugMode) {
      debugPrint('[overview] GET $uri');
      debugPrint('[overview] tokenLen=${token.length}');
    }

    final resp = await http.get(uri, headers: _headers(token));

    if (resp.statusCode != 200) _throwHttp(resp, uri);

    return ReportOverviewDto.fromJson(jsonDecode(resp.body));
  }

  Future<List<DailyRevenuePointDto>> getRevenueDaily({
    required DateTime from,
    required DateTime to,
    int? cinemaId,
  }) async {
    final token = await _requireToken('revenue-daily');

    final uri = Uri.parse('$baseUrl/auth/admin/reports/revenue-daily').replace(
      queryParameters: {
        'from': _fmt(from),
        'to': _fmt(to),
        if (cinemaId != null) 'cinemaId': cinemaId.toString(),
      },
    );

    if (kDebugMode) {
      debugPrint('[revenue-daily] GET $uri');
      debugPrint('[revenue-daily] tokenLen=${token.length}');
    }

    final resp = await http.get(uri, headers: _headers(token));

    if (resp.statusCode != 200) _throwHttp(resp, uri);

    final raw = jsonDecode(resp.body);
    if (raw is! List) throw 'Response không phải List';

    return raw
        .cast<Map<String, dynamic>>()
        .map(DailyRevenuePointDto.fromJson)
        .toList();
  }
}
