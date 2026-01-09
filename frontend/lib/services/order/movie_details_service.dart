import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../model/movie_details.dart';

class MovieDetailsService {
  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    final response = await http.get(Uri.parse('$BASE_URL/movies/$movieId'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return MovieDetailsModel.fromApi(jsonData);
    }

    throw Exception('Failed to load movie details');
  }
}
