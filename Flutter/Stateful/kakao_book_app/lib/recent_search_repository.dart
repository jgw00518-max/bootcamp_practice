import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchRepository {
  const RecentSearchRepository();

  static const _storageKey = 'recent_book_searches';
  static const _maxCount = 10;

  /// Loads saved keywords in newest-first order.
  Future<List<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_storageKey) ?? [];
  }

  /// Saves a keyword once, moves repeated searches to the top, and keeps ten.
  Future<List<String>> add(String keyword) async {
    final searches = await load();
    searches.remove(keyword);
    searches.insert(0, keyword);
    final savedSearches = searches.take(_maxCount).toList();
    await _save(savedSearches);
    return savedSearches;
  }

  /// Removes one keyword from local recent searches.
  Future<List<String>> remove(String keyword) async {
    final searches = await load();
    searches.remove(keyword);
    await _save(searches);
    return searches;
  }

  /// Removes all locally saved search keywords.
  Future<void> clear() async => _save([]);

  Future<void> _save(List<String> searches) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_storageKey, searches);
  }
}
