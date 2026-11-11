import 'package:codex_navigtor_class_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('홈에서 First Page와 Second Page로 이동한다', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Go to the Screen #1'));
    await tester.pumpAndSettle();
    expect(find.text('Screen 1st'), findsWidgets);

    await tester.tap(find.byKey(const Key('first_page_back_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Go to the Screen #2'));
    await tester.pumpAndSettle();
    expect(find.text('Screen 2nd'), findsWidgets);
  });
}
