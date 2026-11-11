import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_crud_app/view/delete_students.dart';
import 'package:riverpod_crud_app/view/insert_students.dart';
import 'package:riverpod_crud_app/view/update_students.dart';
import 'package:riverpod_crud_app/vm/student_notifier.dart';

class QueryStudents extends ConsumerWidget {
  const QueryStudents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riverpod CRUD for students'),
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
      body: studentAsync.when(
        data: (data) {
          return data.isEmpty
          ? Center(child: Text('학생 정보가 없습니다.'))
          : ListView.builder( 
              itemCount: data.length,
              itemBuilder: (context, index) {
                final s = data[index];
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
            );
        }, 
        error: (error, stackTrace) => Center(child: Text('에러발생 : $error'),), 
        loading: () => Center(child: CircularProgressIndicator(),),
      )
    );
  }
}
