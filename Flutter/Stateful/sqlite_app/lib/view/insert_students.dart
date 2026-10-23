import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlite_app/model/students.dart';
import 'package:sqlite_app/vm/database_handler.dart';

class InsertStudents extends StatefulWidget {
  const InsertStudents({super.key});

  @override
  State<InsertStudents> createState() => _InsertStudentsState();
}

class _InsertStudentsState extends State<InsertStudents> {

  DatabaseHandler handler = DatabaseHandler();  // Database controller
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController deptController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert for SQLite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: '학번을 입력하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '성명을 입력하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: deptController,
                decoration: InputDecoration(
                  labelText: '전공을 입력하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호를 입력하세요'
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => insertAction(), 
              child: Text('입력')
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  Future<void> insertAction() async{
    Students students = Students(
      code: codeController.text.trim(),
      name: nameController.text.trim(), 
      dept: deptController.text.trim(), 
      phone: phoneController.text.trim()
    );
    int result = await handler.insertStudents(students);
    if(result == 0 ){
      errorSnackBar();
    }else{
      showDialog();
    }
  }

  void errorSnackBar(){
    Get.snackbar(
      "경고",
      "입력 중 문제가 발생 하였습니다.",
    snackPosition: SnackPosition.TOP,
    colorText: Theme.of(context).colorScheme.onError,
    backgroundColor: Theme.of(context).colorScheme.error
    );
  }

  void showDialog(){
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료 되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          }, 
          child: Text('OK')
        )
      ]
    );
  }
} // class