import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider_json_movie_github_gpt_app/model/movie.dart';

class MovieModel extends ChangeNotifier {
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;

  /// 화면에서는 목록을 읽고, 변경은 ViewModel에서 처리한다.
  List<Movie> get movies => List.unmodifiable(_movies);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMovies() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('https://zeushahn.github.io/Test/movies.json');

      final respose = await http.get(url).timeout(const Duration(seconds: 15));

      if (respose.statusCode != 200) {
        throw Exception('Http ${respose.statusCode}');
      }

      final decoded =
          jsonDecode(utf8.decode(respose.bodyBytes)) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>;

      _movies = results
          .map((item) => Movie.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      _error = '영화 목록을 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
