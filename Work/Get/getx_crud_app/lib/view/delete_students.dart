import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/student_handler.dart';

class DeleteStudents extends StatelessWidget {
  DeleteStudents({super.key});

  final codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    codeController.text = args[0];
    final studentHandler = Get.find<StudentHandler>();

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
                final result = await studentHandler.deleteStudent(codeController.text);
                if (result == 'OK') {
                  Get.back();
                  Get.snackbar('삭제 완료', '학생 정보가 삭제되었습니다');
                } else {
                  Get.snackbar('삭제 실패', '오류가 발생했습니다');
                }
              },
              child: const Text('삭제'),
            )
          ],
        ),
      ),
    );
  }
}
