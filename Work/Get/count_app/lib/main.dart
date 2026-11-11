import 'package:count_app/view/home.dart';
import 'package:count_app/vm/counter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  Get.put(Counter()); // 주입 : 싱글톤(재귀)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
    );
  }
}
