import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:json_pixabay_app/app.dart';
import 'package:json_pixabay_app/features/images/data/pixabay_api.dart';
import 'package:json_pixabay_app/features/images/data/local_image_repository.dart';
import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('empty search displays an input warning', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byType(Card), findsOneWidget);
  });

  test('API requests 20 images with the selected page and filters', () async {
    late Uri requestedUri;
    final api = PixabayApi(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"totalHits": 1, "hits": [{"id": 1, "webformatURL": "https://example.com/preview.jpg", "largeImageURL": "https://example.com/original.jpg", "tags": "cat", "user": "tester", "likes": 2, "views": 3, "downloads": 4}]}',
          200,
        );
      }),
    );

    final result = await api.search(
      query: 'cat image',
      page: 2,
      filter: const PixabaySearchFilter(
        imageType: PixabayImageType.illustration,
        orientation: PixabayOrientation.horizontal,
        category: 'animals',
      ),
    );

    expect(requestedUri.queryParameters['per_page'], '20');
    expect(requestedUri.queryParameters['page'], '2');
    expect(requestedUri.queryParameters['image_type'], 'illustration');
    expect(requestedUri.queryParameters['orientation'], 'horizontal');
    expect(requestedUri.queryParameters['category'], 'animals');
    expect(result.images.single.userName, 'tester');
    expect(result.images.single.downloads, 4);
  });

  test('recent searches and favorites persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = LocalImageRepository();
    await repository.saveRecentSearch('cat');
    await repository.saveRecentSearch('dog');
    await repository.saveRecentSearch('cat');
    expect(await repository.loadRecentSearches(), ['cat', 'dog']);

    const image = PixabayImage(
      id: 10,
      previewUrl: 'https://example.com/preview.jpg',
      largeImageUrl: 'https://example.com/original.jpg',
      tags: 'cat',
      userName: 'tester',
      likes: 1,
      views: 2,
      downloads: 3,
    );
    expect(await repository.toggleFavorite(image), isTrue);
    expect((await repository.loadFavorites()).single.id, 10);
    expect(await repository.toggleFavorite(image), isFalse);
    expect(await repository.loadFavorites(), isEmpty);
  });
}
