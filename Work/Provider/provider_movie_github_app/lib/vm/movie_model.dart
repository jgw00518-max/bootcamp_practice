import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/movie.dart';

/// 영화 조회와 실행 중의 수정·삭제를 관리하고 화면에 변경을 알린다.
class MovieModel extends ChangeNotifier {
  MovieModel({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;
  final http.Client _client;
  final bool _ownsClient;
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  List<Movie> get movies => List.unmodifiable(_movies);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// JSON 조회 결과와 로딩·오류 상태를 화면에 전달한다.
  Future<void> fetchMovies() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.get(
        Uri.parse('https://zeushahn.github.io/Test/movies.json'),
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final movies = (decoded['results'] as List)
          .map((item) => Movie.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      if (_disposed) return;
      _movies = movies;
    } catch (_) {
      if (_disposed) return;
      _error = '영화 목록을 불러오지 못했습니다.';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// 확인된 영화를 현재 목록에서 제거한다.
  void deleteMovie(Movie movie) {
    _movies.remove(movie);
    notifyListeners();
  }

  /// 포스터를 유지하고 저장한 제목을 목록에 반영한다.
  void updateMovie(Movie movie, String title) {
    final index = _movies.indexOf(movie);
    if (index < 0) return;
    _movies[index] = movie.copyWith(title: title);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_ownsClient) _client.close();
    super.dispose();
  }
}
