import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../model/must_eat_place.dart';
import '../model/app_preferences.dart';
import '../model/place_sort_option.dart';
import '../model/app_backup.dart';
import 'geocoding_service.dart';
import 'location_service.dart';
import 'must_eat_place_database.dart';

/// 맛집 목록 상태와 검색·분류·CRUD 흐름을 View에서 분리해 관리한다.
class MustEatPlaceViewModel extends ChangeNotifier {
  MustEatPlaceViewModel({
    MustEatPlaceDataSource? dataSource,
    AppSettingsDataSource? settingsDataSource,
    LocationDataSource? locationDataSource,
    AddressDataSource? addressDataSource,
    BackupDataSource? backupDataSource,
  }) : _dataSource = dataSource ?? MustEatPlaceDatabase.instance,
       _settingsDataSource =
           settingsDataSource ??
           (dataSource is AppSettingsDataSource
               ? dataSource as AppSettingsDataSource
               : dataSource == null
               ? MustEatPlaceDatabase.instance
               : null),
       _locationDataSource =
           locationDataSource ?? const DeviceLocationService(),
       _addressDataSource = addressDataSource ?? const DeviceGeocodingService(),
       _backupDataSource =
           backupDataSource ??
           (dataSource is BackupDataSource
               ? dataSource as BackupDataSource
               : dataSource == null
               ? MustEatPlaceDatabase.instance
               : null);

  /// 실제 앱에서는 SQLite, 테스트에서는 가짜 저장소를 가리킨다.
  final MustEatPlaceDataSource _dataSource;

  /// 실제 앱에서는 SQLite 설정 저장소이며 기존 가짜 저장소 테스트에서는 null이다.
  final AppSettingsDataSource? _settingsDataSource;

  /// 가까운 거리순을 선택할 때 현재 좌표를 제공하는 위치 저장소다.
  final LocationDataSource _locationDataSource;

  /// 주소 검색과 좌표의 도로명 주소 변환을 담당하는 데이터 소스입니다.
  final AddressDataSource _addressDataSource;

  /// 전체 사용자 데이터를 내보내거나 교체할 SQLite 백업 저장소다.
  final BackupDataSource? _backupDataSource;

  List<MustEatPlace> _places = const [];
  List<String> _categories = const [];
  String _searchQuery = '';
  String _selectedCategory = '전체';
  bool _favoritesOnly = false;
  bool _loading = false;
  Object? _loadError;
  bool _isDarkMode = false;
  AppThemeColor _themeColor = AppThemeColor.coral;
  PlaceSortOption _sortOption = PlaceSortOption.newest;
  UserLocation? _currentLocation;

  /// SQLite에서 읽은 전체 맛집 목록이다.
  List<MustEatPlace> get places => List.unmodifiable(_places);

  /// 사용자 설정에서 관리하며 홈 TabBar와 입력 폼에 사용하는 카테고리다.
  List<String> get categories => List.unmodifiable(_categories);

  /// 홈에 표시할 전체 레코드 개수다.
  int get totalCount => _places.length;

  /// 전체 또는 현재 선택한 카테고리에 저장된 카드 개수를 반환한다.
  int get selectedCategoryCount {
    if (_selectedCategory == '전체') return totalCount;
    return _places.where((place) => place.category == _selectedCategory).length;
  }

  /// 이름 검색에 사용 중인 문자열이다.
  String get searchQuery => _searchQuery;

  /// 홈에서 선택한 음식 분류다.
  String get selectedCategory => _selectedCategory;

  /// true이면 즐겨찾기로 지정한 맛집만 홈 목록에 표시한다.
  bool get favoritesOnly => _favoritesOnly;

  /// 최초 또는 CRUD 이후 목록을 읽는 동안의 상태다.
  bool get loading => _loading;

  /// 목록 조회가 실패했을 때 View에 표시할 오류다.
  Object? get loadError => _loadError;

  /// 앱 전체에 적용할 다크모드 선택 상태다.
  bool get isDarkMode => _isDarkMode;

  /// 버튼, 탭, 강조 영역에 적용할 사용자 선택 포인트 색상이다.
  AppThemeColor get themeColor => _themeColor;

  /// 홈 목록에 현재 적용된 정렬 기준이다.
  PlaceSortOption get sortOption => _sortOption;

  /// 거리 정렬과 지도에서 함께 사용하는 가장 최근의 기기 위치다.
  UserLocation? get currentLocation => _currentLocation;

  /// 이름 검색과 카테고리 조건을 모두 만족하는 화면용 목록이다.
  List<MustEatPlace> get filteredPlaces {
    final query = _searchQuery.trim().toLowerCase();
    final places = _places
        .where(
          (place) =>
              (_selectedCategory == '전체' ||
                  place.category == _selectedCategory) &&
              (!_favoritesOnly || place.isFavorite) &&
              (query.isEmpty || place.name.toLowerCase().contains(query)),
        )
        .toList();
    places.sort(_comparePlaces);
    return places;
  }

  /// 선택한 기준을 적용하며 가까운 거리순일 때만 현재 위치를 먼저 조회한다.
  Future<void> setSortOption(PlaceSortOption option) async {
    if (option == PlaceSortOption.distance) {
      await findCurrentLocation();
    }
    _sortOption = option;
    notifyListeners();
  }

  /// 위치 권한을 확인해 현재 좌표를 저장하고 지도와 정렬 화면에 공유한다.
  Future<UserLocation> findCurrentLocation({bool refresh = false}) async {
    if (!refresh && _currentLocation != null) return _currentLocation!;
    final location = await _locationDataSource.getCurrentLocation();
    _currentLocation = location;
    notifyListeners();
    return location;
  }

  /// 현재 위치가 준비된 경우 맛집까지의 거리를 화면용 문자열로 반환합니다.
  String? distanceLabel(MustEatPlace place) {
    final location = _currentLocation;
    if (location == null) return null;
    final meters = _distanceFrom(location, place);
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  /// 입력한 주소를 검색하여 지도에서 사용할 좌표와 표시 주소를 반환합니다.
  Future<AddressLocation> findLocationByAddress(String address) {
    return _addressDataSource.findByAddress(address);
  }

  /// 지도에서 선택한 좌표를 사용자가 읽을 수 있는 주소로 변환합니다.
  Future<String> findAddress(double latitude, double longitude) {
    return _addressDataSource.findAddress(latitude, longitude);
  }

  int _comparePlaces(MustEatPlace first, MustEatPlace second) {
    switch (_sortOption) {
      case PlaceSortOption.newest:
        return _compareNewest(first, second);
      case PlaceSortOption.name:
        return first.name.compareTo(second.name);
      case PlaceSortOption.rating:
        final ratingResult = second.rating.compareTo(first.rating);
        return ratingResult != 0 ? ratingResult : _compareNewest(first, second);
      case PlaceSortOption.favorite:
        final favoriteResult = (second.isFavorite ? 1 : 0).compareTo(
          first.isFavorite ? 1 : 0,
        );
        return favoriteResult != 0
            ? favoriteResult
            : _compareNewest(first, second);
      case PlaceSortOption.distance:
        final location = _currentLocation;
        if (location == null) return _compareNewest(first, second);
        return _distanceFrom(
          location,
          first,
        ).compareTo(_distanceFrom(location, second));
    }
  }

  int _compareNewest(MustEatPlace first, MustEatPlace second) {
    final dateResult = second.initDate.compareTo(first.initDate);
    if (dateResult != 0) return dateResult;
    return (second.seq ?? 0).compareTo(first.seq ?? 0);
  }

  /// 두 위경도 사이의 대권거리를 미터 단위로 계산한다.
  double _distanceFrom(UserLocation location, MustEatPlace place) {
    const earthRadius = 6371000.0;
    double radians(double degrees) => degrees * math.pi / 180;
    final latitudeDelta = radians(place.lat - location.latitude);
    final longitudeDelta = radians(place.lng - location.longitude);
    final startLatitude = radians(location.latitude);
    final endLatitude = radians(place.lat);
    final value =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(startLatitude) *
            math.cos(endLatitude) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(value), math.sqrt(1 - value));
  }

  /// 저장소의 최신 목록을 읽고 View에 상태 변경을 알린다.
  Future<void> loadPlaces() async {
    _loading = true;
    _loadError = null;
    notifyListeners();
    try {
      _places = await _dataSource.findAll();
      _categories = await _dataSource.findCategories();
      final preferences = await _settingsDataSource?.findPreferences();
      if (preferences != null) {
        _isDarkMode = preferences.isDarkMode;
        _themeColor = preferences.themeColor;
      }
      if (_selectedCategory != '전체' &&
          !_categories.contains(_selectedCategory)) {
        _selectedCategory = '전체';
      }
    } catch (error) {
      _loadError = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 다크모드를 즉시 반영하고 SQLite에 선택값을 저장한다.
  Future<void> setDarkMode(bool enabled) async {
    _isDarkMode = enabled;
    notifyListeners();
    await _settingsDataSource?.saveDarkMode(enabled);
  }

  /// 포인트 색상을 즉시 반영하고 SQLite에 선택값을 저장한다.
  Future<void> setThemeColor(AppThemeColor color) async {
    _themeColor = color;
    notifyListeners();
    await _settingsDataSource?.saveThemeColor(color);
  }

  /// 현재 SQLite 상태를 파일 서비스가 저장할 수 있는 스냅샷으로 반환한다.
  Future<AppBackup> createBackup() async {
    final dataSource = _backupDataSource;
    if (dataSource == null) throw StateError('백업 기능을 사용할 수 없습니다.');
    return dataSource.createBackup();
  }

  /// 백업 데이터로 SQLite를 교체한 뒤 모든 화면 상태를 다시 불러온다.
  Future<void> restoreBackup(AppBackup backup) async {
    final dataSource = _backupDataSource;
    if (dataSource == null) throw StateError('복원 기능을 사용할 수 없습니다.');
    await dataSource.restoreBackup(backup);
    await loadPlaces();
  }

  /// 검색어를 변경하고 현재 메모리 목록을 즉시 다시 필터링한다.
  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  /// 선택한 카테고리로 현재 메모리 목록을 즉시 다시 필터링한다.
  void setCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  /// 사용자 입력을 정리한 뒤 새 카테고리를 저장하고 목록을 갱신한다.
  Future<void> addCategory(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('카테고리 이름을 입력해 주세요.');
    }
    if (_categories.contains(trimmedName)) {
      throw StateError('이미 존재하는 카테고리입니다.');
    }
    await _dataSource.insertCategory(trimmedName);
    await loadPlaces();
  }

  /// 사용하지 않는 카테고리를 삭제하고 TabBar 목록을 갱신한다.
  Future<void> deleteCategory(String name) async {
    await _dataSource.deleteCategory(name);
    await loadPlaces();
  }

  /// 즐겨찾기 전용 필터의 활성화 상태를 전환한다.
  void toggleFavoritesOnly() {
    _favoritesOnly = !_favoritesOnly;
    notifyListeners();
  }

  /// 새 맛집을 저장한 뒤 전체 목록과 개수를 갱신한다.
  Future<void> addPlace(MustEatPlace place) async {
    await _dataSource.insert(place);
    await loadPlaces();
  }

  /// 기존 맛집을 수정한 뒤 전체 목록을 갱신한다.
  Future<void> updatePlace(MustEatPlace place) async {
    await _dataSource.update(place);
    await loadPlaces();
  }

  /// 카드의 즐겨찾기 값을 반전해 저장하고 목록을 갱신한다.
  Future<void> toggleFavorite(MustEatPlace place) async {
    await _dataSource.update(place.copyWith(isFavorite: !place.isFavorite));
    await loadPlaces();
  }

  /// 맛집을 삭제한 뒤 전체 목록과 개수를 갱신한다.
  Future<void> deletePlace(int seq) async {
    await _dataSource.delete(seq);
    await loadPlaces();
  }
}
