import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlite_app/model/students.dart';
import 'package:sqlite_app/vm/database_handler.dart';

class UpdateStudents extends StatefulWidget {
  const UpdateStudents({super.key});

  @override
  State<UpdateStudents> createState() => _UpdateStudentsState();
}

class _UpdateStudentsState extends State<UpdateStudents> {

  DatabaseHandler handler = DatabaseHandler();  // Database controller
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController deptController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  
  var value = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    codeController.text = value[0];
    nameController.text = value[1];
    deptController.text = value[2];
    phoneController.text = value[3];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update for SQLite'),
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
                  labelText: '학번'
                ),
                readOnly: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '성명을 수정하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: deptController,
                decoration: InputDecoration(
                  labelText: '전공을 수정하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호를 수정하세요'
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => updateAction(), 
              child: Text('수정')
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  Future<void> updateAction() async{
    Students students = Students(
      code: codeController.text.trim(),
      name: nameController.text.trim(), 
      dept: deptController.text.trim(), 
      phone: phoneController.text.trim()
    );
    int result = await handler.updateStudents(students);
    if(result == 0 ){
      errorSnackBar();
    }else{
      showDialog();
    }
  }

  void errorSnackBar(){
    Get.snackbar(
      "경고",
      "수정 중 문제가 발생 하였습니다.",
    snackPosition: SnackPosition.TOP,
    colorText: Theme.of(context).colorScheme.onError,
    backgroundColor: Theme.of(context).colorScheme.error
    );
  }

  void showDialog(){
    Get.defaultDialog(
      title: '수정 결과',
      middleText: '수정이 완료 되었습니다.',
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