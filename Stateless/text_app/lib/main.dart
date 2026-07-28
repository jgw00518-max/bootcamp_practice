import 'package:flutter/material.dart';
import 'package:text_app/text02_app.dart';
import 'package:text_app/text_ex_app.dart';
import 'package:text_app/text_ex_app2.dart';


import 'home.dart';

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
      home: const TextExApp2(),
    );
  }
}