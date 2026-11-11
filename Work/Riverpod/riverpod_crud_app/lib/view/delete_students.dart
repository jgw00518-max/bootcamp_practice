import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_crud_app/vm/student_notifier.dart';

class DeleteStudents extends ConsumerWidget {
  final String code;

  DeleteStudents({
    super.key,
    required this.code
  });

  final codeController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    codeController.text = code;
    final studentNotifier = ref.read(studentNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Delete Student")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              readOnly: true,
              decoration: const InputDecoration(labelText: '학번', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await studentNotifier.deleteStudent(codeController.text);
                if (result == 'OK') {
                  if(!context.mounted) return;  // await 이후에 context가 여전히 유효한지 확인
                  Navigator.of(context).pop();
                  showSnackBar(context, '학생 정보가 삭제되었습니다..', Colors.blue);
                } else {
                  if(!context.mounted) return;
                  showSnackBar(context, '오류가 발생했습니다.', Colors.red);
                }
              },
              child: const Text('삭제'),
            )
          ],
        ),
      ),
    );
  }

    void showSnackBar(BuildContext context, String str, Color color){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(str),
        duration: Duration(seconds: 1),
        backgroundColor: color,
      )
    );
  }
}
