import 'package:bmi_image_app/view/home.dart';
import 'package:bmi_image_app/vm/calc_bmi_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  Get.put(CalcBmiModel());
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
      home: Home(),
    );
  }
}
