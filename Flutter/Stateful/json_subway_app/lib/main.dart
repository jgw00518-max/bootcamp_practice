import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'features/subway/presentation/subway_home_page.dart';

void main() => runApp(const MyApp());

/// 서울 지하철 도착정보 앱의 공통 테마와 첫 화면을 설정합니다.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.client,
    this.refreshInterval = const Duration(seconds: 30),
  });

  /// 테스트에서 실제 네트워크 호출을 대체할 HTTP 클라이언트입니다.
  final http.Client? client;

  /// 도착 정보 자동 갱신 주기이며 기본값은 30초입니다.
  final Duration refreshInterval;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: '서울 지하철',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457D6)),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      useMaterial3: true,
    ),
    home: SubwayHomePage(client: client, refreshInterval: refreshInterval),
  );
}
