import 'package:drawer_ex_app/mail.dart';
import 'package:drawer_ex_app/receivedmail.dart';
import 'package:drawer_ex_app/sendmail.dart';
import 'package:flutter/material.dart';

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
      routes: {
        '/' :(context) => Mail(),
        '/send' :(context) => Sendmail(),
        '/received' :(context) => Receivedmail(),
      },
      initialRoute: '/',
    );
  }
}