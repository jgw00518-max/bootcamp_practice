import 'package:flutter/material.dart';
import 'package:json_pixabay_app/features/home/presentation/home.dart';

/// Pixabay 이미지 검색 앱의 최상위 설정이다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pixabay Image Search',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}
