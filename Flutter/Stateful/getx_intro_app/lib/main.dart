import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_intro_app/home.dart';
import 'package:getx_intro_app/third_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
      getPages: [
        GetPage(
          name: '/third', // third page (페이지 내용) 
          page: () => ThirdPage(),
        ),
        GetPage(                      // Get.toNamed를 썼을때 transition은 main에서 고쳐야함
          name: '/third2',            // 생성을 여기에서 하기 때문.
          page: () => ThirdPage(),  
          transition: Transition.cupertino,
          transitionDuration: Duration(seconds: 5)
        ),
      ],
    );
  }
}