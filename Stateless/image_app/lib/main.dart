import 'package:flutter/material.dart';
import 'package:image_app/image01_app.dart';
import 'package:image_app/image01_app_2.dart';
import 'package:image_app/image_app_2.dart';
import 'package:image_app/image_app_3.dart';
import 'package:image_app/image_app_4.dart';

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
      home: const Image01App2(),
    );
  }
}