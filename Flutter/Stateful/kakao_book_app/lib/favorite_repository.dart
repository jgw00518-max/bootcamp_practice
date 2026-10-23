import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRepository {
  const FavoriteRepository();

  static const _storageKey = 'favorite_books';

  /// Returns all locally saved favorite book documents.
  Future<List<Map<String, dynamic>>> loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_storageKey) ?? [])
        .map(
          (value) => Map<String, dynamic>.from(
            jsonDecode(value) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Toggles the selected book and returns whether it is now a favorite.
  Future<bool> toggle(Map<String, dynamic> book) async {
    final favorites = await loadFavorites();
    final index = favorites.indexWhere(
      (item) => _bookKey(item) == _bookKey(book),
    );
    if (index >= 0) {
      favorites.removeAt(index);
      await _save(favorites);
      return false;
    }

    favorites.add(book);
    await _save(favorites);
    return true;
  }

  /// Checks whether the book is included in local favorites.
  Future<bool> isFavorite(Map<String, dynamic> book) async {
    final favorites = await loadFavorites();
    return favorites.any((item) => _bookKey(item) == _bookKey(book));
  }

  Future<void> _save(List<Map<String, dynamic>> favorites) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      favorites.map(jsonEncode).toList(),
    );
  }

  String _bookKey(Map<String, dynamic> book) {
    return book['isbn']?.toString().isNotEmpty == true
        ? book['isbn'].toString()
        : book['url']?.toString() ?? book['title']?.toString() ?? '';
  }
}
