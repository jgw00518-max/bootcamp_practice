import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:json_movie_github_app/view/home.dart';

import 'package:provider/provider.dart';
import 'package:json_movie_github_app/vm/movie_model.dart';

void main() {
  Future<void> loadMovies(WidgetTester tester, {int count = 2}) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'results': List.generate(
            count,
            (index) => {
              'title': 'Movie $index',
              'image': 'https://example.com/$index.jpg',
            },
          ),
        }),
        200,
      ),
    );
    addTearDown(client.close);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MovieModel(client: client)..fetchMovies(),
        child: const MaterialApp(home: Home()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('alternating colors and delete confirmation', (tester) async {
    await loadMovies(tester);
    final colors = tester
        .widgetList<Container>(find.byType(Container))
        .map((container) => container.color);
    expect(colors, contains(const Color(0xFF655A73)));
    expect(colors, contains(const Color(0xFF805568)));

    await tester.drag(find.byType(Slidable).first, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Movie 0'), findsOneWidget);

    await tester.drag(find.byType(Slidable).first, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('Movie 0'), findsNothing);
    expect(find.text('Movie 1'), findsOneWidget);
  });

  testWidgets('right swipe edits title and rejects blank title', (
    tester,
  ) async {
    await loadMovies(tester);
    await tester.drag(find.byType(Slidable).first, const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Movie 0'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Edit'));
    await tester.pumpAndSettle();
    expect(find.text('제목을 입력해 주세요.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Updated title');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Updated title'), findsOneWidget);

    await tester.drag(find.byType(Slidable).first, const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Discarded title');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Discarded title'), findsNothing);
  });

  testWidgets('deleting last movie shows empty state', (tester) async {
    await loadMovies(tester, count: 1);
    await tester.drag(find.byType(Slidable), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('영화 목록이 없습니다.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
