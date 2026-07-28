import 'package:flutter/material.dart';
import 'package:navigator_ex/third_page.dart';

import 'first_page.dart';
import 'home.dart';
import 'second_page.dart';

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
      routes: { // 경로와 이름을 미리 정해준다.
        '/' :(context) => Home(),
        '/1st' :(context) => FirstPage(),
        '/2nd' :(context) => SecondPage(),
        '/3rd' :(context) => ThirdPage(),
      },
      initialRoute: '/',
    );
  }
}
