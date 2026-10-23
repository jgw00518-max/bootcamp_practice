import 'dart:convert';

import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 최근 검색어와 즐겨찾기 이미지를 기기에 영구 저장한다.
class LocalImageRepository {
  static const _recentSearchesKey = 'recent_searches';
  static const _favoritesKey = 'favorite_images';

  /// 중복을 제거하고 가장 최근 검색어부터 최대 10개를 저장한다.
  Future<List<String>> saveRecentSearch(String query) async {
    final preferences = await SharedPreferences.getInstance();
    final searches = <String>{
      query,
      ...preferences.getStringList(_recentSearchesKey) ?? const <String>[],
    }.take(10).toList();
    await preferences.setStringList(_recentSearchesKey, searches);
    return searches;
  }

  /// 저장된 최근 검색어를 최근 순서대로 불러온다.
  Future<List<String>> loadRecentSearches() async =>
      (await SharedPreferences.getInstance()).getStringList(
        _recentSearchesKey,
      ) ??
      const [];

  /// 저장 여부를 반전시키고 변경 뒤의 즐겨찾기 상태를 반환한다.
  Future<bool> toggleFavorite(PixabayImage image) async {
    final favorites = await loadFavorites();
    final index = favorites.indexWhere((item) => item.id == image.id);
    if (index >= 0) {
      favorites.removeAt(index);
      await _saveFavorites(favorites);
      return false;
    }
    await _saveFavorites([image, ...favorites]);
    return true;
  }

  /// 기기에 저장된 즐겨찾기 목록을 반환한다.
  Future<List<PixabayImage>> loadFavorites() async {
    final raw = (await SharedPreferences.getInstance()).getString(
      _favoritesKey,
    );
    if (raw == null) return [];
    final values = jsonDecode(raw) as List<dynamic>;
    return values
        .map((value) => PixabayImage.fromJson(value as Map<String, dynamic>))
        .toList();
  }

  /// 특정 이미지가 즐겨찾기에 있는지 확인한다.
  Future<bool> isFavorite(int id) async =>
      (await loadFavorites()).any((image) => image.id == id);

  Future<void> _saveFavorites(List<PixabayImage> images) async {
    await (await SharedPreferences.getInstance()).setString(
      _favoritesKey,
      jsonEncode(images.map((image) => image.toJson()).toList()),
    );
  }
}
