import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_crud_app/vm/student_handler.dart';
import '../model/student.dart';

class InsertStudents extends StatelessWidget {
  InsertStudents({super.key});

  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final studentHandler = Get.find<StudentHandler>();

    return Scaffold(
      appBar: AppBar(title: const Text("Insert Student")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("학번", codeController),
            _buildTextField("성명", nameController),
            _buildTextField("전공", deptController),
            _buildTextField("전화번호", phoneController),
            _buildTextField("주소", addressController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final student = Student(
                  code: codeController.text,
                  name: nameController.text,
                  dept: deptController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                );
                final result = await studentHandler.insertStudent(student);
                if (result == 'OK') {
                  Get.back();
                  Get.snackbar('입력 완료', '학생 정보가 등록되었습니다');
                } else {
                  Get.snackbar('입력 실패', '오류가 발생했습니다');
                }
              },
              child: const Text('입력'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
