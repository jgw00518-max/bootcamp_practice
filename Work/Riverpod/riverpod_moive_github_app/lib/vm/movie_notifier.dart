import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../model/movie.dart';

/// 영화 조회와 실행 중의 수정·삭제를 관리하고 화면에 변경을 알린다.
class MovieNotifier extends AsyncNotifier<List<Movie>> {
  @override
  FutureOr<List<Movie>> build() async{
    return fetchMovies();
  }

  /// JSON 조회 결과와 로딩·오류 상태를 화면에 전달한다.
  Future<List<Movie>> fetchMovies() async {
    final respose = await http.get(Uri.parse('https://zeushahn.github.io/Test/movies.json'));

    if(respose.statusCode != 200) {
      throw Exception('영화 목록을 불러오지 못했습니다.');
    }

    final decoded = jsonDecode(utf8.decode(respose.bodyBytes)) as Map<String, dynamic>;

    return (decoded['results'] as List).map((e) => Movie.fromJson(Map<String, dynamic>.from(e as Map)),).toList();
  }

  /// 다시 조회한 결과를 로딩, 성공, 오류 상태로 전달한다.
  Future<void> refreshMovies() async {
    if(state.isLoading) return;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(fetchMovies);
    if(!ref.mounted) return;
    state = result;
  }

  /// 확인된 영화를 현재 목록에서 제거한다.
  void deleteMovie(Movie movie) {
    final movies = state.asData?.value;
    if(movies == null) return;

    state = AsyncData([
      for(final item in movies)
        if(!identical(item, movie)) item,
    ]);
  }
  /// 선택한 영화의 제목을 바꾸고 새 목록을 전달한다.
  void updateMovie(Movie movie, String title) {
    final movies = state.asData?.value;
    if (movies == null) return;

    state = AsyncData([
      for (final item in movies)
        identical(item, movie)
            ? item.copyWith(title: title)
            : item,
      ]);
    }
  }

final movieNotifierProvider =AsyncNotifierProvider<MovieNotifier, List<Movie>>(MovieNotifier.new,);