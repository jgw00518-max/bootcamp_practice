import 'package:codex_textfield_switch_calc_app/view/home.dart';
import 'package:flutter/material.dart';

/// 앱을 시작하고 최상위 위젯을 실행합니다.
void main() => runApp(const MyApp());

/// 계산기 앱의 전역 테마와 첫 화면을 구성합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 앱의 Material 설정과 홈 화면을 생성합니다.
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: '간단한 계산기',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: false,
    ),
    home: const Home(),
  );
}
