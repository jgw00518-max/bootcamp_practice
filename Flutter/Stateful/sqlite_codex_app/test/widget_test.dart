import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_codex_app/main.dart';
import 'package:sqlite_codex_app/model/student.dart';
import 'package:sqlite_codex_app/view/update_page.dart';

void main() {
  testWidgets('홈에서 학생 등록 화면으로 이동한다', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('SQLite for Students'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add_student_button')));
    await tester.pumpAndSettle();

    expect(find.text('학생 등록'), findsOneWidget);
    expect(find.text('학번을 입력하세요'), findsOneWidget);
    expect(find.text('성명을 입력하세요'), findsOneWidget);
  });

  testWidgets('수정 화면에서 학번은 읽기 전용이다', (tester) async {
    const student = Student(
      code: 'S001',
      name: '유비',
      department: '경영학과',
      phone: '001',
    );

    await tester.pumpWidget(
      const MaterialApp(home: UpdatePage(student: student)),
    );

    final codeField = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );
    expect(codeField.readOnly, isTrue);
    expect(find.text('유비'), findsOneWidget);
    expect(find.text('경영학과'), findsOneWidget);
  });
}
