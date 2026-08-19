import 'package:flutter_test/flutter_test.dart';

import 'package:codex_snackbar_app/main.dart';

void main() {
  testWidgets('shows the snack bar screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Snack Bar'), findsOneWidget);
    expect(find.text('Snackbar Button'), findsOneWidget);
  });
}
