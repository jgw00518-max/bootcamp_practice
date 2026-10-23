import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_crud_app/view/delete_students.dart';
import 'package:getx_crud_app/view/insert_students.dart';
import 'package:getx_crud_app/view/update_students.dart';
import 'package:getx_crud_app/vm/student_handler.dart';

class QueryStudents extends StatelessWidget {
  const QueryStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final studentHandler = Get.find<StudentHandler>();
    studentHandler.fetchStudents();

    return Scaffold(
      appBar: AppBar(
        title: Text('GetX CRUD for students'),
        actions: [
          IconButton(
            onPressed: () => Get.to(InsertStudents()), 
            icon: Icon(Icons.add)
          )
        ],
      ),
      body: Obx(
        () => studentHandler.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : studentHandler.students.isEmpty
              ? Center(child: Text('학생 정보가 없습니다.'))
              : ListView.builder( 
                  itemCount: studentHandler.students.length,
                  itemBuilder: (context, index) {
                    final s = studentHandler.students[index];
                    return ListTile(
                      title: Text('${s.name} (${s.code})'),
                      subtitle: Text('${s.dept} | ${s.phone}'),
                      onTap: () => Get.to(UpdateStudents(), arguments: [
                        s.code, s.name, s.dept, s.phone, s.address
                      ]),
                      onLongPress: () => Get.to(DeleteStudents(), arguments: [s.code]),
                  );
                },
              ),
      ),
    );
  }
}
