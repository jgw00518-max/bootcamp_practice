import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_json_movie_github_gpt_app/vm/movie_model.dart';

/// ViewModel의 조회 상태와 영화 목록을 구독해 포스터와 제목을 표시한다.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // notifyListeners()가 호출되면 변경된 조회 상태와 목록으로 화면을 갱신한다.
    final model = context.watch<MovieModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('영화 목록')),
      body: _buildBody(context, model),
    );
  }

  /// 구독한 ViewModel의 상태에 따라 안내 또는 영화 목록을 표시한다.
  Widget _buildBody(BuildContext context, MovieModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(model.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: model.fetchMovies,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    return model.movies.isEmpty
        ? const Center(child: Text('표시할 영화가 없습니다.'))
        : RefreshIndicator(
            onRefresh: model.fetchMovies,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: model.movies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = model.movies[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Image.network(
                          movie.image,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                width: 80,
                                height: 120,
                                child: Icon(Icons.broken_image_outlined),
                              ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            movie.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
