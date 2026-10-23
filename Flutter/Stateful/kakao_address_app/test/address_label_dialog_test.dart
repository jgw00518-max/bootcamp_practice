import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_address_app/widgets/address_label_dialog.dart';

void main() {
  testWidgets('별칭을 입력하고 저장하면 다이얼로그가 정상적으로 닫힌다', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const AddressLabelDialog(
                    initialLabel: '',
                    isEditing: false,
                  ),
                );
              },
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('address_label_dialog_field')),
      '집',
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(result, '집');
    expect(find.byKey(const Key('address_label_dialog_field')), findsNothing);
  });
}
