import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_json_movie_github_app/view/home.dart';
import 'package:provider_json_movie_github_app/vm/movie_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MovieModel()..fetchMovies(),
      child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
    );
  }
}
