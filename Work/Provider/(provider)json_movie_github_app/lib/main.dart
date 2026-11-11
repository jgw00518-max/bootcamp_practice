import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:json_movie_github_app/view/home.dart';
import 'package:json_movie_github_app/vm/movie_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 앱 전체에 영화 ViewModel을 제공한다.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieModel()..fetchMovies(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const Home(),
      ),
    );
  }
}
