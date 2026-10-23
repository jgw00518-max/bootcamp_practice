import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // ★ GetStorage 사용
import 'package:pokedex_app/view/login_view.dart';
import 'package:pokedex_app/view/region_view.dart';
import 'package:pokedex_app/view/signup_view.dart';

void main() async {
  // ★ GetStorage 초기화
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex App',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFE53935),
          primary: Color(0xFFE53935),    // 🔴 포켓몬 레드
          secondary: Color(0xFF3B5BA7),  // 🔵 포켓몬 블루
          tertiary: Color(0xFFFBC02D),   // 🟡 피카츄 옐로우
        ),
      ),

      // ★ 앱 시작 화면
      initialRoute: '/',

      getPages: [
        GetPage(
          name: '/',
          page: () => const LoginView(), // ★ 로그인 화면
        ),

        GetPage(
          name: '/signup',
          page: () => const SignupView(), // ★ 회원가입 화면
        ),

        GetPage(
          name: '/region',
          page: () => const RegionView(), // ★ 로그인 성공 후 지방 선택 화면
        ),
      ],
    );
  } // build
} // class
