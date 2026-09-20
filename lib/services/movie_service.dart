import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';

class MovieService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  Future<List<Movie>> fetchTrendingMovies() async {
    if (apiKey.isEmpty) {
      throw Exception('TMDB API key is missing. Please check your .env file.');
    }
    final uri = Uri.parse(
      '$baseUrl/trending/movie/week?api_key=$apiKey&language=en-US',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load movies. Status: ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  Future<Movie> fetchMovieDetails(int movieId) async {
    if (apiKey.isEmpty) {
      throw Exception('TMDB API key is missing. Please check your .env file.');
    }
    final uri = Uri.parse(
      '$baseUrl/movie/$movieId?api_key=$apiKey&language=en-US',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load movie details. Status: ${response.statusCode}',
      );
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    return Movie.fromJson(data);
  }
}
