// Gọi API backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ExampleService {
  Future<List<dynamic>> getMovies() async {
    final response = await http.get(Uri.parse('$BASE_URL/movies'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lấy danh sách phim thất bại');
    }
  }
}