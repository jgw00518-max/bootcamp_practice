import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_crud_app/vm/student_provider.dart';
import '../model/student.dart';

class UpdateStudents extends StatelessWidget {
  final String code;
  final String name;
  final String dept;
  final String phone;
  final String address;

  UpdateStudents({
    super.key,
    required this.code,
    required this.name,
    required this.dept,
    required this.phone,
    required this.address
  });

  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    codeController.text = code;
    nameController.text = name;
    deptController.text = dept;
    phoneController.text = phone;
    addressController.text = address;

    final studentModel = context.read<StudentModel>(); 

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
                final result = await studentModel.updateStudent(student);
                if (result == 'OK') {
                  if(!context.mounted) return;  // await 이후에 context가 여전히 유효한지 확인
                  Navigator.of(context).pop();
                  showSnackBar(context, '학생 정보가 수정되었습니다..', Colors.blue);
                } else {
                  if(!context.mounted) return;
                  showSnackBar(context, '오류가 발생했습니다.', Colors.red);
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
