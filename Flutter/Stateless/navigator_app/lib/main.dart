import 'package:flutter/material.dart';
import 'package:navigator_app/first_page.dart';
import 'package:navigator_app/second_page.dart';
import 'package:navigator_app/third_page.dart';


void main() {
  runApp(const MyApp());
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
      home: const FirstPage(),
    );
  }
}