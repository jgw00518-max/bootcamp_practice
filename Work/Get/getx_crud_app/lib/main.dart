import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_crud_app/view/query_students.dart';
import 'package:getx_crud_app/vm/student_handler.dart';

void main() {
  Get.put(StudentHandler());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const QueryStudents(),
    );
  }
}
