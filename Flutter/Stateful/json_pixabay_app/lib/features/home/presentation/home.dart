import 'package:flutter/material.dart';
import 'package:json_pixabay_app/features/images/data/pixabay_api.dart';
import 'package:json_pixabay_app/features/images/data/local_image_repository.dart';
import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';
import 'package:json_pixabay_app/features/images/presentation/favorites_page.dart';
import 'package:json_pixabay_app/features/images/presentation/image_detail_page.dart';

const _categories = <String>[
  'animals',
  'backgrounds',
  'fashion',
  'nature',
  'people',
  'science',
  'technology',
];

/// 검색어, 필터, 페이지 목록 상태를 관리하는 Pixabay 첫 화면이다.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.api});
  final PixabayApi? api;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final PixabayApi _api;
  late final LocalImageRepository _localRepository;
  List<String> _recentSearches = const [];
  List<PixabayImage> _images = const [];
  PixabaySearchFilter _filter = const PixabaySearchFilter();
  String _query = '';
  String? _errorMessage;
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  bool _hasMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? PixabayApi();
    _localRepository = LocalImageRepository();
    _scrollController.addListener(_loadMoreWhenNeeded);
    _loadRecentSearches();
  }

  /// 앱을 다시 열어도 남아 있는 최근 검색어를 화면에 불러온다.
  Future<void> _loadRecentSearches() async {
    final searches = await _localRepository.loadRecentSearches();
    if (mounted) setState(() => _recentSearches = searches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 목록 끝 근처에서만 다음 20개 페이지를 요청한다.
  void _loadMoreWhenNeeded() {
    if (_scrollController.position.extentAfter < 300) {
      _loadMore();
    }
  }

  /// 새 검색이나 필터 변경 시 기존 목록을 페이지 1 결과로 교체한다.
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = '검색어를 입력하세요.');
      return;
    }
    FocusScope.of(context).unfocus();
    final recentSearches = await _localRepository.saveRecentSearch(query);
    setState(() {
      _query = query;
      _page = 1;
      _isInitialLoading = true;
      _errorMessage = null;
      _hasSearched = true;
      _recentSearches = recentSearches;
    });
    try {
      final result = await _api.search(query: query, page: 1, filter: _filter);
      if (!mounted) return;
      setState(() {
        _images = result.images;
        _hasMore = result.images.length < result.totalHits;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = '이미지를 불러오지 못했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  /// 선택한 최근 검색어를 입력창에 넣고 즉시 다시 검색한다.
  void _searchRecent(String query) {
    _searchController.text = query;
    _search();
  }

  /// 이미 표시한 목록 뒤에 다음 API 페이지를 안전하게 이어 붙인다.
  Future<void> _loadMore() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore || _query.isEmpty) {
      return;
    }
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final result = await _api.search(
        query: _query,
        page: nextPage,
        filter: _filter,
      );
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _images = [..._images, ...result.images];
        _hasMore =
            _images.length < result.totalHits && result.images.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('다음 이미지를 불러오지 못했습니다.')));
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _showFilterSheet() async {
    var selectedType = _filter.imageType;
    var selectedOrientation = _filter.orientation;
    String? selectedCategory = _filter.category;
    final filter = await showModalBottomSheet<PixabaySearchFilter>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Search filter',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PixabayImageType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Image type'),
                  items: PixabayImageType.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setSheetState(() => selectedType = value!),
                ),
                DropdownButtonFormField<PixabayOrientation>(
                  initialValue: selectedOrientation,
                  decoration: const InputDecoration(labelText: 'Orientation'),
                  items: PixabayOrientation.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setSheetState(() => selectedOrientation = value!),
                ),
                DropdownButtonFormField<String?>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ..._categories.map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    ),
                  ],
                  onChanged: (value) =>
                      setSheetState(() => selectedCategory = value),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    PixabaySearchFilter(
                      imageType: selectedType,
                      orientation: selectedOrientation,
                      category: selectedCategory,
                    ),
                  ),
                  child: const Text('Apply filter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (filter == null) return;
    setState(() => _filter = filter);
    if (_searchController.text.trim().isNotEmpty) await _search();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('PixaBay Image Search'),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_outline),
          tooltip: 'Favorites',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FavoritesPage(repository: _localRepository),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Search filter',
          onPressed: _showFilterSheet,
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onSubmitted: (_) => _search(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Enter a search term',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
            ),
          ),
        ),
        if (_recentSearches.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _recentSearches.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ActionChip(
                label: Text(_recentSearches[index]),
                onPressed: () => _searchRecent(_recentSearches[index]),
              ),
            ),
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _MessageCard(message: _errorMessage!),
          ),
        Expanded(child: _buildBody()),
      ],
    ),
  );

  Widget _buildBody() {
    if (_isInitialLoading) return const _ImageGridSkeleton();
    if (!_hasSearched) return const Center(child: Text('검색어를 입력해 이미지를 찾아보세요.'));
    if (_images.isEmpty) return _EmptyResult(query: _query);
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _images.length + (_isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= _images.length) return const _SkeletonCard();
        final image = _images[index];
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ImageDetailPage(image: image)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image.previewUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const _SkeletonCard(),
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFFE5E7EB),
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 검색 결과가 없을 때 검색어 변경을 안내한다.
class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.query});
  final String query;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_search, size: 64),
          const SizedBox(height: 16),
          Text(
            '"$query" 검색 결과가 없습니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('다른 검색어 또는 필터로 다시 찾아보세요.', textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

/// 이미지가 네트워크에서 내려오는 동안 카드 자리와 동일한 골격을 표시한다.
class _ImageGridSkeleton extends StatelessWidget {
  const _ImageGridSkeleton();
  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.all(12),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: 8,
    itemBuilder: (_, _) => const _SkeletonCard(),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
