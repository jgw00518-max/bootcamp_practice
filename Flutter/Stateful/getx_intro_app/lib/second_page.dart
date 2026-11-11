import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // Property
  var value = Get.arguments ?? "__"; // Null 값이 들어온 경우 __ 반환

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.back(), 
              child: Text("Exit"),
            ),
            Text(
              "Single arguments : $value"
            ),
            Text(
              "Multiple Argument #1 : ${value[0]}"
            ),
            Text(
              "Multiple Argument #2 : ${value[1]}"
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: "Good"), 
              child: Text("Reply"),
            ),
          ],
        ),
      ),
    );
  }
}