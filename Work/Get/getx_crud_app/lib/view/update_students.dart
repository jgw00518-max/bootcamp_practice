import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_crud_app/vm/student_handler.dart';
import '../model/student.dart';

class UpdateStudents extends StatelessWidget {
  UpdateStudents({super.key});

  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    codeController.text = args[0];
    nameController.text = args[1];
    deptController.text = args[2];
    phoneController.text = args[3];
    addressController.text = args[4];

    final studentHandler = Get.find<StudentHandler>();

    return Scaffold(
      appBar: AppBar(title: const Text("Update Student")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("학번", codeController, readOnly: true),
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
                final result = await studentHandler.updateStudent(student);
                if (result == 'OK') {
                  Get.back();
                  Get.snackbar('수정 완료', '학생 정보가 수정되었습니다');
                } else {
                  Get.snackbar('수정 실패', '오류가 발생했습니다');
                }
              },
              child: const Text('수정'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
