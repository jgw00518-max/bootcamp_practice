import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';

import '../model/must_eat_place.dart';
import '../model/place_sort_option.dart';
import '../vm/must_eat_place_view_model.dart';
import 'place_form_page.dart';
import 'place_detail_sheet.dart';
import 'user_settings_page.dart';
import 'all_places_map_page.dart';

/// ViewModel의 맛집 상태를 화면에 표시하고 사용자 동작을 전달한다.
class Home extends StatefulWidget {
  const Home({super.key, this.viewModel});

  /// 테스트에서는 주입할 수 있으며 실제 앱에서는 기본 ViewModel을 생성한다.
  final MustEatPlaceViewModel? viewModel;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final MustEatPlaceViewModel _viewModel;
  late final bool _ownsViewModel;
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? MustEatPlaceViewModel();

    // 상위 ListenableBuilder의 build 중 notifyListeners가 호출되지 않도록
    // 첫 프레임이 완성된 다음 SQLite 데이터를 불러온다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeHome();
    });
  }

  /// 목록을 불러온 뒤 현재 위치를 조회하며, 위치 조회 실패는 목록 사용을 막지 않습니다.
  Future<void> _initializeHome() async {
    await _viewModel.loadPlaces();
    try {
      await _viewModel.findCurrentLocation();
    } catch (error) {
      if (!mounted) return;
      final message = error
          .toString()
          .replaceFirst('Bad state: ', '')
          .replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: '설정',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel) _viewModel.dispose();
    super.dispose();
  }

  /// 추가 또는 수정 화면을 열고 같은 ViewModel로 저장 상태를 공유한다.
  Future<void> _openForm([MustEatPlace? place]) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceFormPage(viewModel: _viewModel, place: place),
      ),
    );
  }

  /// 페이지 이동 없이 화면 아래에서 선택한 맛집의 지도와 상세 정보를 보여준다.
  Future<void> _showPlaceDetail(MustEatPlace place) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (context) => FractionallySizedBox(
        key: const Key('place_detail_sheet'),
        heightFactor: 0.92,
        child: PlaceDetailSheet(
          place: place,
          distanceLabel: _viewModel.distanceLabel(place),
        ),
      ),
    );
  }

  /// 정렬 기준 BottomSheet를 열고 선택 결과를 ViewModel에 적용한다.
  Future<void> _showSortOptions() async {
    final selected = await showModalBottomSheet<PlaceSortOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '목록 정렬',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...PlaceSortOption.values.map(
                (option) => ListTile(
                  key: Key('sort_option_${option.name}'),
                  onTap: () => Navigator.pop(context, option),
                  leading: Icon(_sortIcon(option)),
                  title: Text(option.label),
                  trailing: option == _viewModel.sortOption
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;

    try {
      await _viewModel.setSortOption(selected);
    } catch (error) {
      if (!mounted) return;
      final message = error
          .toString()
          .replaceFirst('Bad state: ', '')
          .replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  IconData _sortIcon(PlaceSortOption option) {
    return switch (option) {
      PlaceSortOption.newest => Icons.schedule_rounded,
      PlaceSortOption.name => Icons.sort_by_alpha_rounded,
      PlaceSortOption.rating => Icons.star_rounded,
      PlaceSortOption.favorite => Icons.favorite_rounded,
      PlaceSortOption.distance => Icons.near_me_rounded,
    };
  }

  /// 사용자 확인 후 ViewModel에 삭제를 요청한다.
  Future<void> _deletePlace(MustEatPlace place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('맛집 삭제'),
        content: Text('${place.name}을(를) 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || place.seq == null) return;

    await _viewModel.deletePlace(place.seq!);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('${place.name}을(를) 삭제했습니다.'),
        action: SnackBarAction(
          key: const Key('undo_delete_button'),
          label: '실행 취소',
          onPressed: () => _restoreDeletedPlace(place),
        ),
      ),
    );
  }

  /// 방금 삭제한 맛집 객체를 같은 기본 키로 다시 저장해 삭제를 취소합니다.
  Future<void> _restoreDeletedPlace(MustEatPlace place) async {
    try {
      await _viewModel.addPlace(place);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제를 취소하지 못했습니다: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) => switch (_selectedNavigationIndex) {
          0 => _buildBody(),
          1 => AllPlacesMapPage(viewModel: _viewModel, embedded: true),
          _ => UserSettingsPage(viewModel: _viewModel, embedded: true),
        },
      ),
      floatingActionButton: _selectedNavigationIndex == 0
          ? FloatingActionButton.extended(
              key: const Key('add_place_button'),
              onPressed: _openForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('맛집 추가'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavigationIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedNavigationIndex = index);
        },
        destinations: const [
          NavigationDestination(
            key: Key('places_navigation'),
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant_rounded),
            label: '맛집 목록',
          ),
          NavigationDestination(
            key: Key('map_navigation'),
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: '전체 지도',
          ),
          NavigationDestination(
            key: Key('settings_navigation'),
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '사용자 설정',
          ),
        ],
      ),
    );
  }

  /// 선택한 하단 메뉴에 맞는 제목을 표시하고 목록 화면의 정보 계층을 유지합니다.
  PreferredSizeWidget _buildAppBar() {
    if (_selectedNavigationIndex == 0) {
      return AppBar(
        toolbarHeight: 76,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘은 어디서 먹을까요?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2),
            Text('맛집 목록'),
          ],
        ),
      );
    }
    return AppBar(
      title: Text(_selectedNavigationIndex == 1 ? '전체 맛집 지도' : '사용자 설정'),
    );
  }

  /// ViewModel 상태에 맞춰 로딩·검색·필터·목록 화면을 구성한다.
  Widget _buildBody() {
    if (_viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('목록을 불러오지 못했습니다: ${_viewModel.loadError}'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _viewModel.loadPlaces,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                '나의 맛집',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '전체 ${_viewModel.totalCount}곳',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${_viewModel.selectedCategoryCount}곳',
                key: const Key('place_total_count'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    key: const Key('place_search_field'),
                    onChanged: _viewModel.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: '맛집 이름을 검색해 보세요',
                      prefixIcon: Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const Key('favorite_filter_button'),
                onPressed: _viewModel.toggleFavoritesOnly,
                tooltip: _viewModel.favoritesOnly ? '즐겨찾기 해제' : '즐겨찾기만 보기',
                isSelected: _viewModel.favoritesOnly,
                icon: const Icon(Icons.star_outline_rounded),
                selectedIcon: const Icon(Icons.star_rounded),
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const Key('sort_button'),
                onPressed: _showSortOptions,
                tooltip: '목록 정렬',
                icon: Icon(_sortIcon(_viewModel.sortOption)),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_viewModel.categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: DefaultTabController(
              key: ValueKey(_viewModel.categories.join('|')),
              length: _viewModel.categories.length + 1,
              initialIndex: [
                '전체',
                ..._viewModel.categories,
              ].indexOf(_viewModel.selectedCategory),
              child: TabBar(
                key: const Key('category_tab_bar'),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                dividerColor: Colors.transparent,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                onTap: (index) {
                  final categories = ['전체', ..._viewModel.categories];
                  _viewModel.setCategory(categories[index]);
                },
                tabs: ['전체', ..._viewModel.categories].map((category) {
                  final count = category == '전체'
                      ? _viewModel.totalCount
                      : _viewModel.places
                            .where((place) => place.category == category)
                            .length;
                  return Tab(text: '$category $count');
                }).toList(),
              ),
            ),
          ),
        Expanded(child: _buildPlaceList()),
      ],
    );
  }

  /// 필터 결과에 따라 안내문 또는 슬라이드 카드 목록을 표시한다.
  Widget _buildPlaceList() {
    final places = _viewModel.filteredPlaces;
    if (_viewModel.places.isEmpty) {
      return _EmptyState(
        icon: Icons.ramen_dining_rounded,
        title: '아직 저장한 맛집이 없어요',
        message: '첫 맛집을 추가하고 나만의 목록을 만들어 보세요.',
        actionLabel: '첫 맛집 추가',
        onAction: _openForm,
      );
    }
    if (places.isEmpty) {
      final query = _viewModel.searchQuery.trim();
      return _EmptyState(
        icon: Icons.search_off_rounded,
        title: '검색 결과가 없어요',
        message: query.isEmpty
            ? '선택한 조건에 해당하는 맛집이 없습니다.'
            : "'$query'에 해당하는 맛집이 없습니다.",
      );
    }

    return RefreshIndicator(
      onRefresh: _viewModel.loadPlaces,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: places.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final place = places[index];
          return _PlaceCard(
            place: place,
            distanceLabel: _viewModel.distanceLabel(place),
            onTap: () => _showPlaceDetail(place),
            onEdit: () => _openForm(place),
            onDelete: () => _deletePlace(place),
            onFavorite: () => _viewModel.toggleFavorite(place),
          );
        },
      ),
    );
  }
}

/// 카드 터치와 양방향 슬라이드 동작을 맛집 한 건에 연결한다.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.distanceLabel,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });

  final MustEatPlace place;
  final String? distanceLabel;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(place.seq),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: Icons.edit,
            label: '수정',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            key: Key('delete_place_${place.seq}'),
            onPressed: (_) => onDelete(),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            icon: Icons.delete,
            label: '삭제',
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 122,
            child: Row(
              children: [
                SizedBox(
                  width: 116,
                  height: double.infinity,
                  child: place.image == null
                      ? Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 38,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Image.memory(place.image!, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 4, 13),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.category,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (place.rating > 0) ...[
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF4A825),
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                place.rating.toStringAsFixed(1),
                                key: Key('card_rating_${place.seq}'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.address.trim().isEmpty
                                    ? '주소 정보 없음'
                                    : place.address,
                                key: Key('card_address_${place.seq}'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (distanceLabel != null) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.near_me_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                distanceLabel!,
                                key: Key('card_distance_${place.seq}'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  key: Key('favorite_${place.seq}'),
                  onPressed: onFavorite,
                  tooltip: place.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                  icon: Icon(
                    place.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: place.isFavorite
                        ? const Color(0xFFF4A825)
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 데이터가 없거나 필터 결과가 비었을 때 다음 행동을 안내한다.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('empty_add_place_button'),
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
