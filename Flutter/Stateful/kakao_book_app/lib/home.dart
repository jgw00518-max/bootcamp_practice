import 'dart:convert';

import 'package:kakao_book_app/book_detail.dart';
import 'package:kakao_book_app/favorite_books_page.dart';
import 'package:kakao_book_app/favorite_repository.dart';
import 'package:kakao_book_app/recent_search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key, this.initialBooks = const []});

  /// Tests may provide books to render without making a network request.
  final List<Map<String, dynamic>> initialBooks;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Stores the Kakao API documents shown by the list.
  late List<Map<String, dynamic>> _books;

  /// Holds the book title entered in the search field.
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minimumPriceController = TextEditingController();
  final TextEditingController _maximumPriceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FavoriteRepository _favoriteRepository = const FavoriteRepository();
  final RecentSearchRepository _recentSearchRepository =
      const RecentSearchRepository();
  bool _isLoading = false;
  String _searchTarget = 'title';

  /// Keeps the API result order by default so appended pages remain in place.
  String _sortType = 'default';
  bool _onlyNormalSale = false;
  List<String> _recentSearches = [];
  String _activeQuery = '';
  String _activeSearchTarget = 'title';
  int _currentPage = 0;
  bool _isEnd = true;
  bool _isLoadingMore = false;

  /// Applies search-result filters and sort order without losing API data.
  List<Map<String, dynamic>> get _visibleBooks {
    final minimumPrice = int.tryParse(_minimumPriceController.text);
    final maximumPrice = int.tryParse(_maximumPriceController.text);
    final books = _books.where((book) {
      final price = _bookPrice(book['sale_price']);
      return (!_onlyNormalSale ||
              book['status'] == '\u{C815}\u{C0C1}\u{D310}\u{B9E4}') &&
          (minimumPrice == null || (price != null && price >= minimumPrice)) &&
          (maximumPrice == null || (price != null && price <= maximumPrice));
    }).toList();

    if (_sortType == 'title') {
      books.sort(
        (first, second) => (first['title']?.toString() ?? '').compareTo(
          second['title']?.toString() ?? '',
        ),
      );
    } else if (_sortType == 'price') {
      books.sort(
        (first, second) => _sortPrice(
          first['sale_price'],
        ).compareTo(_sortPrice(second['sale_price'])),
      );
    }
    return books;
  }

  int _sortPrice(dynamic value) {
    final price = _bookPrice(value);
    return price == null || price < 0 ? 1 << 62 : price;
  }

  int? _bookPrice(dynamic value) {
    final price = value is num ? value.toInt() : int.tryParse('$value');
    return price == null || price < 0 ? null : price;
  }

  @override
  void initState() {
    super.initState();
    _books = List.of(widget.initialBooks);
    _scrollController.addListener(_loadMoreWhenScrolledToEnd);
    _loadRecentSearches();
  }

  /// Starts loading the next page when the list approaches its bottom edge.
  void _loadMoreWhenScrolledToEnd() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 200) {
      _loadMore();
    }
  }

  /// Restores recent search chips from local storage.
  Future<void> _loadRecentSearches() async {
    final searches = await _recentSearchRepository.load();
    if (mounted) setState(() => _recentSearches = searches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minimumPriceController.dispose();
    _maximumPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('bookSearchField'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _getJsonData(),
          decoration: InputDecoration(
            hintText:
                '\u{CC45} \u{C81C}\u{BAA9}\u{C744} \u{C785}\u{B825}\u{D558}\u{C138}\u{C694}',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('favoriteBooksButton'),
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    FavoriteBooksPage(repository: _favoriteRepository),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      key: const Key('searchTargetDropdown'),
                      value: _searchTarget,
                      items: const [
                        DropdownMenuItem(
                          value: 'title',
                          child: Text('\u{C81C}\u{BAA9}'),
                        ),
                        DropdownMenuItem(
                          value: 'person',
                          child: Text('\u{C791}\u{AC00}'),
                        ),
                        DropdownMenuItem(
                          value: 'publisher',
                          child: Text('\u{CD9C}\u{D310}\u{C0AC}'),
                        ),
                        DropdownMenuItem(value: 'isbn', child: Text('ISBN')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _searchTarget = value);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      key: const Key('sortDropdown'),
                      value: _sortType,
                      items: const [
                        DropdownMenuItem(
                          value: 'default',
                          child: Text('\u{AE30}\u{BCF8} \u{C815}\u{B82C}'),
                        ),
                        DropdownMenuItem(
                          value: 'price',
                          child: Text('\u{AC00}\u{ACA9}\u{C21C}'),
                        ),
                        DropdownMenuItem(
                          value: 'title',
                          child: Text('\u{C774}\u{B984}\u{C21C}'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _sortType = value);
                      },
                    ),
                    const Spacer(),
                    FilterChip(
                      key: const Key('normalSaleFilter'),
                      label: const Text(
                        '\u{C815}\u{C0C1}\u{D310}\u{B9E4}\u{B9CC}',
                      ),
                      selected: _onlyNormalSale,
                      onSelected: (selected) {
                        setState(() => _onlyNormalSale = selected);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: TextField(
                        key: const Key('minimumPriceField'),
                        controller: _minimumPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: '\u{CD5C}\u{C18C}\u{AC00}',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('~'),
                    ),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        key: const Key('maximumPriceField'),
                        controller: _maximumPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: '\u{CD5C}\u{B300}\u{AC00}',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_recentSearches.isNotEmpty)
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(left: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentSearches.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final keyword = _recentSearches[index];
                        return InputChip(
                          label: Text(keyword),
                          onPressed: () {
                            _searchController.text = keyword;
                            _getJsonData();
                          },
                          onDeleted: () async {
                            final searches = await _recentSearchRepository
                                .remove(keyword);
                            if (mounted) {
                              setState(() => _recentSearches = searches);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  TextButton(
                    key: const Key('clearRecentSearchesButton'),
                    onPressed: () async {
                      await _recentSearchRepository.clear();
                      if (mounted) setState(() => _recentSearches = []);
                    },
                    child: const Text('\u{C804}\u{CCB4} \u{C0AD}\u{C81C}'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _visibleBooks.isEmpty
                ? const Center(
                    child: Text(
                      '\u{B370}\u{C774}\u{D130}\u{AC00} \u{C5C6}\u{C2B5}\u{B2C8}\u{B2E4}.',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _visibleBooks.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _visibleBooks.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final book = _visibleBooks[index];
                      return _BookCard(
                        book: book,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookDetailPage(
                              book: book,
                              repository: _favoriteRepository,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading || _isLoadingMore ? null : _getJsonData,
        child: const Icon(Icons.file_download),
      ),
    );
  }

  /// Starts a new search from the first Kakao result page.
  Future<void> _getJsonData() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '\u{AC80}\u{C0C9}\u{D560} \u{CC45} \u{C81C}\u{BAA9}\u{C744} \u{C785}\u{B825}\u{D558}\u{C138}\u{C694}.',
          ),
        ),
      );
      return;
    }

    final searches = await _recentSearchRepository.add(query);
    if (!mounted) return;
    setState(() {
      _recentSearches = searches;
      _activeQuery = query;
      _activeSearchTarget = _searchTarget;
    });

    await _requestPage(page: 1, replaceResults: true);
  }

  /// Requests the next page for the current query when additional results exist.
  Future<void> _loadMore() async {
    if (_isLoadingMore || _isEnd || _activeQuery.isEmpty) return;
    await _requestPage(page: _currentPage + 1, replaceResults: false);
  }

  /// Retrieves one page and either replaces or appends its documents.
  Future<void> _requestPage({
    required int page,
    required bool replaceResults,
  }) async {
    if (replaceResults && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      if (replaceResults) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final response = await http.get(
        Uri.https('dapi.kakao.com', '/v3/search/book', {
          'target': _activeSearchTarget,
          'query': _activeQuery,
          'page': '$page',
          'size': '10',
        }),
        headers: {'Authorization': 'KakaoAK afb4256fd1905ac83f240e1f7f7c4f56'},
      );
      if (response.statusCode != 200) {
        throw Exception();
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final documents = json['documents'] as List<dynamic>? ?? [];
      final meta = json['meta'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        final nextBooks = documents.cast<Map<String, dynamic>>();
        _books = replaceResults ? nextBooks : [..._books, ...nextBooks];
        _currentPage = page;
        _isEnd = meta['is_end'] as bool? ?? nextBooks.isEmpty;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '\u{B3C4}\u{C11C} \u{C815}\u{BCF4}\u{B97C} \u{BD88}\u{B7EC}\u{C624}\u{C9C0} \u{BABB}\u{D588}\u{C2B5}\u{B2C8}\u{B2E4}.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book, required this.onTap});

  final Map<String, dynamic> book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final authors = (book['authors'] as List<dynamic>? ?? []).join(', ');
    final thumbnail = book['thumbnail'] as String? ?? '';

    return Card(
      color: const Color(0xfffbf5ff),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                height: 108,
                child: thumbnail.isEmpty
                    ? const ColoredBox(color: Color(0xffe9e0ee))
                    : Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: Color(0xffe9e0ee)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] as String? ??
                          '\u{C81C}\u{BAA9} \u{C5C6}\u{C74C}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authors.isEmpty
                          ? '\u{C791}\u{AC00} \u{C815}\u{BCF4} \u{C5C6}\u{C74C}'
                          : authors,
                    ),
                    Text(_salePriceText(book['sale_price'])),
                    Text(
                      book['status'] as String? ??
                          '\u{C0C1}\u{D0DC} \u{C815}\u{BCF4} \u{C5C6}\u{C74C}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats valid sale prices and turns missing or negative prices into text.
  String _salePriceText(dynamic salePrice) {
    final price = salePrice is num
        ? salePrice.toInt()
        : int.tryParse(salePrice?.toString() ?? '');
    if (price == null || price < 0) {
      return '\u{D310}\u{B9E4}\u{AC00}\u{ACA9} \u{C815}\u{BCF4} \u{C5C6}\u{C74C}';
    }

    final formattedPrice = price.toString().replaceAllMapped(
      RegExp(r'(?<!^)(?=(\d{3})+$)'),
      (_) => ',',
    );
    return '$formattedPrice\u{C6D0}';
  }
}
