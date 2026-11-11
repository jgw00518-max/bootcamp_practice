import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider_json_movie_github_gpt_app/model/movie.dart';
import 'package:provider_json_movie_github_gpt_app/view/home.dart';
import 'package:provider_json_movie_github_gpt_app/vm/movie_model.dart';

class TestMovieModel extends MovieModel {
  bool loading = false;
  String? failure;
  List<Movie> items = [];
  int fetchCount = 0;

  @override
  bool get isLoading => loading;
  @override
  String? get error => failure;
  @override
  List<Movie> get movies => items;
  @override
  Future<void> fetchMovies() async {
    fetchCount++;
  }
}

void main() {
  Future<void> showHome(WidgetTester tester, TestMovieModel model) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<MovieModel>.value(
        value: model,
        child: const MaterialApp(home: Home()),
      ),
    );
  }

  testWidgets('조회 중 로딩 표시', (tester) async {
    await showHome(tester, TestMovieModel()..loading = true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets('영화 제목과 포스터 표시', (tester) async {
    await showHome(
      tester,
      TestMovieModel()
        ..items = [
          Movie(image: 'https://example.com/poster.jpg', title: '테스트 영화'),
        ],
    );
    expect(find.text('테스트 영화'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
  testWidgets('조회 실패 후 재시도', (tester) async {
    final model = TestMovieModel()..failure = '영화 목록을 불러오지 못했습니다.';
    await showHome(tester, model);
    expect(find.text(model.failure!), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    expect(model.fetchCount, 1);
  });
  testWidgets('빈 목록 안내', (tester) async {
    await showHome(tester, TestMovieModel());
    expect(find.text('표시할 영화가 없습니다.'), findsOneWidget);
  });
}
