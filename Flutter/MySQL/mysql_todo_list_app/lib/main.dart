import 'package:flutter/material.dart';
import 'package:mysql_todo_list_app/view/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFFFF9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF9FF),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const Home(),
    );
  }
}
