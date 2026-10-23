import 'package:codex_bmi_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BMI를 계산하고 결과를 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), '170');
    await tester.enterText(find.byType(TextField).at(1), '60');
    await tester.tap(find.text('BMI 계산'));
    await tester.pumpAndSettle();

    expect(find.textContaining('20.8'), findsOneWidget);
    expect(find.textContaining('정상체중'), findsOneWidget);
  });
}
