import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_crud_app/view/query_students.dart';
import 'package:provider_crud_app/vm/student_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StudentModel()..fetchStudents(),
        )
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const QueryStudents(),
    );
  }
}
