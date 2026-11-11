import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../vm/movie_model.dart';

/// ViewModel의 조회 상태에 따라 로딩, 오류, 영화 목록을 표시한다.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider JSON App'),
        centerTitle: true,
      ),
      body: buildBody(context, movieProvider),
    );
  } // build

  // --- Widgets ---
  Widget buildBody(BuildContext context, MovieModel movieModel){
    if(movieModel.isLoading){
      return const Center(child: CircularProgressIndicator(),);
    }

    if(movieModel.error != null){
      return buildError(context, movieModel.error!);
    }

    if(movieModel.movies.isEmpty){
      return const Center(child: Text('영화 목록이 없습니다.'),);
    }

      return buildMovieList(movieModel);
    }

    Widget buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error),
          TextButton(
            onPressed: () {
              context.read<MovieModel>().fetchMovies();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget buildMovieList(MovieModel movieModel) {
    return ListView.builder(
      itemCount: movieModel.movies.length,
      itemBuilder: (context, index) {
        final movie = movieModel.movies[index];

        return Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: index.isEven
                  ? const Color(0xFF655A73)
                  : const Color(0xFF805568),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Image.network(
                    movie.image,
                    width: 100,
                    height: 145,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 100,
                      height: 145,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      movie.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} // class