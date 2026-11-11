import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_json_movie_github_gpt_app/view/home.dart';
import 'package:provider_json_movie_github_gpt_app/vm/movie_model.dart';

void main() => runApp(const MyApp());

/// 영화 ViewModel을 제공하고 홈 화면을 시작 화면으로 연결한다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieModel()..fetchMovies(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '영화 목록',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const Home(),
      ),
    );
  }
}
