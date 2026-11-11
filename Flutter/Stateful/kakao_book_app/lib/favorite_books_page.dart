import 'package:flutter/material.dart';
import 'package:kakao_book_app/book_detail.dart';
import 'package:kakao_book_app/favorite_repository.dart';

class FavoriteBooksPage extends StatefulWidget {
  const FavoriteBooksPage({super.key, required this.repository});

  final FavoriteRepository repository;

  @override
  State<FavoriteBooksPage> createState() => _FavoriteBooksPageState();
}

class _FavoriteBooksPageState extends State<FavoriteBooksPage> {
  late Future<List<Map<String, dynamic>>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = widget.repository.loadFavorites();
  }

  void _reloadFavorites() {
    setState(() => _favorites = widget.repository.loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u{CC1C} \u{BAA9}\u{B85D}')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(
              child: Text(
                '\u{CC1C}\u{D55C} \u{CC45}\u{C774} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.',
              ),
            );
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book['title'] as String? ?? '-'),
                subtitle: Text(
                  (book['authors'] as List<dynamic>? ?? []).join(', '),
                ),
                trailing: const Icon(Icons.favorite, color: Colors.red),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(
                        book: book,
                        repository: widget.repository,
                      ),
                    ),
                  );
                  _reloadFavorites();
                },
              );
            },
          );
        },
      ),
    );
  }
}
