import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mysql_todo_list_app/view/home.dart';

void main() {
  testWidgets('목록을 표시하고 Dialog에서 Todo를 추가한다', (tester) async {
    final todos = <Map<String, dynamic>>[
      {'seq': 1, 'title': '최승욱 약속', 'todo_date': '2026-09-17'},
    ];
    final client = MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/todos') {
        return _jsonResponse({'results': todos});
      }

      if (request.method == 'POST' && request.url.path == '/todos') {
        todos.insert(0, {
          'seq': 2,
          'title': request.bodyFields['title'],
          'todo_date': '2026-09-17',
        });
        return _jsonResponse({'result': 'OK', 'todo': todos.first});
      }

      return _jsonResponse({'detail': 'Not found'}, statusCode: 404);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Home(client: client, baseUrl: 'http://test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('최승욱 약속 / 2026-09-17'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openAddTodoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addTodoButton')));
    await tester.pump();
    expect(find.text('내용을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('todoTitleField')), '미팅 잡기');
    await tester.tap(find.byKey(const Key('addTodoButton')));
    await tester.pumpAndSettle();

    expect(find.text('미팅 잡기 / 2026-09-17'), findsOneWidget);
  });

  testWidgets('왼쪽 스와이프로 삭제하고 삭제 목록을 최근 순서로 표시한다', (tester) async {
    var todos = <Map<String, dynamic>>[
      {'seq': 7, 'title': '볼펜 사기', 'todo_date': '2026-09-17'},
    ];
    final deletedTodos = <Map<String, dynamic>>[
      {
        'seq': 2,
        'todo_seq': 7,
        'title': '볼펜 사기',
        'todo_date': '2026-09-17',
        'delete_time': '2026-09-17T15:00:00',
      },
      {
        'seq': 1,
        'todo_seq': 3,
        'title': '오래된 삭제',
        'todo_date': '2026-09-16',
        'delete_time': '2026-09-16T15:00:00',
      },
    ];
    final client = MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/todos') {
        return _jsonResponse({'results': todos});
      }

      if (request.method == 'POST' && request.url.path == '/todos/delete') {
        expect(request.bodyFields['seq'], '7');
        todos = [];
        return _jsonResponse({'result': 'OK', 'deleted_seq': 2});
      }

      if (request.method == 'GET' && request.url.path == '/deleted-todos') {
        return _jsonResponse({'results': deletedTodos});
      }

      if (request.method == 'POST' &&
          request.url.path == '/deleted-todos/restore') {
        expect(request.bodyFields['seq'], '2');
        final restored = deletedTodos.removeAt(0);
        todos = [
          {
            'seq': 8,
            'title': restored['title'],
            'todo_date': restored['todo_date'],
          },
        ];
        return _jsonResponse({'result': 'OK', 'restored_seq': 8});
      }

      return _jsonResponse({'detail': 'Not found'}, statusCode: 404);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Home(client: client, baseUrl: 'http://test'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('볼펜 사기 / 2026-09-17'), const Offset(-350, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteTodo_7')));
    await tester.pumpAndSettle();

    expect(find.text('볼펜 사기 / 2026-09-17'), findsNothing);
    expect(find.text('삭제 목록으로 이동했습니다.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openDeletedTodosButton')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Lists'), findsOneWidget);
    final recent = tester.getTopLeft(find.text('볼펜 사기 / 2026-09-17'));
    final older = tester.getTopLeft(find.text('오래된 삭제 / 2026-09-16'));
    expect(recent.dy, lessThan(older.dy));

    await tester.drag(find.text('볼펜 사기 / 2026-09-17'), const Offset(350, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('restoreTodo_2')));
    await tester.pumpAndSettle();

    expect(find.text('볼펜 사기 / 2026-09-17'), findsNothing);
    expect(find.text('Todo를 복구했습니다.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Todo Lists'), findsOneWidget);
    expect(find.text('볼펜 사기 / 2026-09-17'), findsOneWidget);
  });

  testWidgets('목록 조회 실패 시 오류와 다시 시도를 표시한다', (tester) async {
    final client = MockClient(
      (_) async => _jsonResponse({'detail': '연결 실패'}, statusCode: 500),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Home(client: client, baseUrl: 'http://test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('연결 실패'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
