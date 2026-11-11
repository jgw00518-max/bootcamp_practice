import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_book_app/recent_search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('keeps ten recent searches in newest-first order', () async {
    SharedPreferences.setMockInitialValues({});
    const repository = RecentSearchRepository();

    for (var index = 1; index <= 11; index++) {
      await repository.add('Book $index');
    }

    expect(await repository.load(), [
      'Book 11',
      'Book 10',
      'Book 9',
      'Book 8',
      'Book 7',
      'Book 6',
      'Book 5',
      'Book 4',
      'Book 3',
      'Book 2',
    ]);

    await repository.remove('Book 11');
    expect((await repository.load()).first, 'Book 10');

    await repository.clear();
    expect(await repository.load(), isEmpty);
  });
}
