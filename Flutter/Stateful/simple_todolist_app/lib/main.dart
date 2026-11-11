import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'view/home.dart';

/// 앱을 실행하고 최상위 위젯을 화면에 표시한다.
void main() {
  runApp(const MyApp());
}

/// TodoList 앱의 테마와 시작 화면을 설정하는 최상위 위젯이다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
