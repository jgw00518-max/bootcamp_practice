import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_python_app/home.dart';
import 'package:flutter_python_app/main.dart';

void main() {
  testWidgets('숫자 입력 및 읽기 전용 결과 필드를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Calc'), findsOneWidget);
    expect(find.text('숫자 입력'), findsOneWidget);
    expect(find.text('결과'), findsOneWidget);

    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    expect(textFields, hasLength(2));
    expect(textFields.last.readOnly, isTrue);
  });

  testWidgets('Calc 버튼이 서버 계산 결과를 결과칸에 표시한다', (WidgetTester tester) async {
    final client = MockClient((request) async {
      expect(request.url.path, '/mul/100');
      return http.Response('{"input": 100, "result": 1000}', 200);
    });

    await tester.pumpWidget(MaterialApp(home: Home(client: client)));
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.tap(find.text('Calc'));
    await tester.pumpAndSettle();

    expect(find.text('1000'), findsOneWidget);
  });
}
