import 'package:flutter_test/flutter_test.dart';

import 'package:codex_character_app/main.dart';

void main() {
  testWidgets('displays the hero card', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('영웅 Card'), findsOneWidget);
    expect(find.text('이순신 장군'), findsOneWidget);
    expect(find.text('62전 62승'), findsOneWidget);
  });
}
