import 'package:flutter/material.dart';
import 'package:json_pixabay_app/features/images/data/local_image_repository.dart';
import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';
import 'package:json_pixabay_app/features/images/presentation/image_detail_page.dart';

/// 기기에 저장한 즐겨찾기 이미지를 별도 목록으로 보여 준다.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.repository});
  final LocalImageRepository repository;
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<PixabayImage>> _favoritesFuture;
  @override
  void initState() {
    super.initState();
    _favoritesFuture = widget.repository.loadFavorites();
  }

  void _reload() =>
      setState(() => _favoritesFuture = widget.repository.loadFavorites());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favorites')),
    body: FutureBuilder<List<PixabayImage>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final images = snapshot.data ?? const [];
        if (images.isEmpty) {
          return const Center(child: Text('No favorite images yet.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageDetailPage(
                      image: image,
                      localRepository: widget.repository,
                    ),
                  ),
                );
                _reload();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(image.previewUrl, fit: BoxFit.cover),
              ),
            );
          },
        );
      },
    ),
  );
}
