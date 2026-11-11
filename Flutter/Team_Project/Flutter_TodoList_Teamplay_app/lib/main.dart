import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'package:todo_ex_app/view/add_view.dart';
import 'package:todo_ex_app/view/login_view.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // ★ 첫 화면 경로
      initialRoute: '/',

      getPages: [

        // ★ 앱 시작 시 TabbarView 실행
        GetPage(
          name: '/',
          page: () => const LoginView(),
        ),

        // AddView 이동 경로
        GetPage(
          name: '/add',
          page: () => const AddView(),
        ),
      ],

      title: 'Flutter Demo',
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A5DBB),
          primary: const Color(0xFF4A5DBB),
          secondary: const Color(0xFF8EA7E9),
          tertiary: const Color(0xFFF4F7FF),
        ),
      ),

      // ★ initialRoute를 사용하므로 home은 사용하지 않음
      // home: const HomeView(),
    );
  }
}