import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_crud_app/view/delete_students.dart';
import 'package:provider_crud_app/view/insert_students.dart';
import 'package:provider_crud_app/view/update_students.dart';
import 'package:provider_crud_app/vm/student_provider.dart';

class QueryStudents extends StatelessWidget {
  const QueryStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final studentModel = context.watch<StudentModel>();
    final students = studentModel.students;

    return Scaffold(
      appBar: AppBar(
        title: Text('Provider CRUD for students'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => InsertStudents(),)
            ), 
            icon: Icon(Icons.add)
          )
        ],
      ),
      body: studentModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : studentModel.students.isEmpty
                ? Center(child: Text('학생 정보가 없습니다.'))
                : ListView.builder( 
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return ListTile(
                        title: Text('${s.name} (${s.code})'),
                        subtitle: Text('${s.dept} | ${s.phone}'),
                        onTap: (){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => UpdateStudents(
                                code: s.code, name: s.name, dept: s.dept, phone: s.phone, address: s.address
                              ),
                            )
                          );
                        },
                        onLongPress: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => DeleteStudents(code: s.code),
                            )
                          );
                        },
                    );
                  },
                ),
    );
  }
}
