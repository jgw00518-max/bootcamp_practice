import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:textfield_calc_rx_app/view/home.dart';
import 'package:textfield_calc_rx_app/vm/calc_model.dart';

void main() {
  Get.put(CalcModel());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
