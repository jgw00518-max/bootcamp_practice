import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../model/movie.dart';
import '../vm/movie_model.dart';

import 'edit_movie.dart';

/// 영화 목록을 구독하고 수정·삭제 동작을 연결한다.
class Home extends StatelessWidget {
  const Home({super.key});

  /// 사용자가 경고창에서 확인한 경우에만 해당 영화를 제거한다.
  Future<void> _deleteMovie(BuildContext context, Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('경고'),
        content: Text('"${movie.title}" 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    context.read<MovieModel>().deleteMovie(movie);
  }

  /// 수정 화면에서 반환한 제목만 목록에 반영한다.
  Future<void> _editMovie(BuildContext context, Movie movie) async {
    final title = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMovie(title: movie.title, imageUrl: movie.image),
      ),
    );
    if (!context.mounted || title == null) return;
    context.read<MovieModel>().updateMovie(movie, title);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MovieModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON & Slider Test'),
        centerTitle: true,
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : model.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(model.error!),
                  TextButton(
                    onPressed: model.fetchMovies,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          : model.movies.isEmpty
          ? const Center(child: Text('영화 목록이 없습니다.'))
          : SlidableAutoCloseBehavior(
              child: ListView.builder(
                itemCount: model.movies.length,
                itemBuilder: (context, index) {
                  final movie = model.movies[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Slidable(
                        key: ObjectKey(movie),
                        // 오른쪽 드래그는 수정, 왼쪽 드래그는 삭제 버튼을 연다.
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _editMovie(context, movie),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteMovie(context, movie),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
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
                    ),
                  );
                },
              ),
            ),
    );
  }
}
