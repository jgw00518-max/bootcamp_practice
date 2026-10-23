import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:must_eat_place_app/model/must_eat_place.dart';
import 'package:must_eat_place_app/model/app_preferences.dart';
import 'package:must_eat_place_app/model/place_sort_option.dart';
import 'package:must_eat_place_app/model/app_backup.dart';
import 'package:must_eat_place_app/view/home.dart';
import 'package:must_eat_place_app/view/place_form_page.dart';
import 'package:must_eat_place_app/vm/must_eat_place_database.dart';
import 'package:must_eat_place_app/vm/must_eat_place_view_model.dart';
import 'package:must_eat_place_app/vm/location_service.dart';
import 'package:must_eat_place_app/vm/geocoding_service.dart';

void main() {
  test('JSON 백업은 맛집과 사용자 설정을 그대로 복원한다', () {
    final source = AppBackup(
      places: _FakeDataSource().places,
      categories: const ['한식', '양식'],
      preferences: const AppPreferences(
        isDarkMode: true,
        themeColor: AppThemeColor.ocean,
      ),
      createdAt: DateTime(2026, 8, 28),
    );

    final restored = AppBackup.fromJsonString(source.toJsonString());

    expect(restored.places.length, 2);
    expect(restored.places.first.rating, 4.5);
    expect(restored.places.first.address, '서울특별시 성동구 연무장길 33');
    expect(restored.categories, ['한식', '양식']);
    expect(restored.preferences.isDarkMode, isTrue);
    expect(restored.preferences.themeColor, AppThemeColor.ocean);
  });

  testWidgets('홈에서 맛집 목록을 표시하고 추가 화면으로 이동한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(
      dataSource: _FakeDataSource(),
      locationDataSource: const _FakeLocationDataSource(),
      addressDataSource: const _FakeAddressDataSource(),
    );
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    expect(find.text('나의 맛집'), findsOneWidget);
    expect(find.text('2곳'), findsOneWidget);
    expect(find.text('삼겹살 집'), findsOneWidget);
    expect(find.byKey(const Key('places_navigation')), findsOneWidget);
    expect(find.byKey(const Key('map_navigation')), findsOneWidget);
    expect(find.byKey(const Key('settings_navigation')), findsOneWidget);
    expect(find.byKey(const Key('add_place_button')), findsOneWidget);
    expect(find.byKey(const Key('card_rating_1')), findsOneWidget);
    expect(find.byKey(const Key('card_distance_1')), findsOneWidget);
    expect(find.byKey(const Key('card_address_1')), findsOneWidget);
    expect(find.text('서울특별시 성동구 연무장길 33'), findsOneWidget);
    expect(find.text('1111-2222'), findsNothing);
    expect(find.text('0m'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_place_button')));
    await tester.pumpAndSettle();

    expect(find.text('맛집 추가'), findsOneWidget);
    expect(find.text('이미지 가져오기'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('place_form_scroll')),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    expect(find.text('위도'), findsNothing);
    expect(find.text('경도'), findsNothing);
    expect(find.byKey(const Key('address_field')), findsOneWidget);
    expect(find.byKey(const Key('category_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('map_location_picker_button')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == '메뉴',
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('map_location_picker_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('지도에서 위치 선택'), findsWidgets);
    expect(find.byKey(const Key('confirm_location_button')), findsOneWidget);
    expect(find.byKey(const Key('current_location_button')), findsOneWidget);
    expect(find.byKey(const Key('current_location_marker')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('address_search_field')),
      '성수동 맛집',
    );
    await tester.tap(find.byKey(const Key('address_search_button')));
    await tester.pumpAndSettle();

    expect(find.text('서울특별시 성동구 연무장길 33'), findsOneWidget);
    expect(find.byKey(const Key('selected_location_marker')), findsOneWidget);
  });

  testWidgets('맛집 수정 화면에서는 좌표를 숨기고 지도 위치 변경을 제공한다', (tester) async {
    final dataSource = _FakeDataSource();
    final viewModel = MustEatPlaceViewModel(
      dataSource: dataSource,
      locationDataSource: const _FakeLocationDataSource(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PlaceFormPage(
          viewModel: viewModel,
          place: dataSource.places.first,
        ),
      ),
    );
    await tester.drag(
      find.byKey(const Key('place_form_scroll')),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.text('위도'), findsNothing);
    expect(find.text('경도'), findsNothing);
    expect(find.byKey(const Key('map_location_picker_button')), findsOneWidget);
    expect(find.text('지도에서 위치 변경'), findsOneWidget);

    await tester.tap(find.byKey(const Key('map_location_picker_button')));
    await tester.pumpAndSettle();

    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(map.options.initialCenter.latitude, dataSource.places.first.lat);
    expect(map.options.initialCenter.longitude, dataSource.places.first.lng);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('address_field')),
      '서울특별시 성동구 성수이로 12',
    );
    expect(find.text('서울특별시 성동구 성수이로 12'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('place_form_scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    final ratingSlider = tester.widget<Slider>(
      find.byKey(const Key('rating_slider')),
    );
    ratingSlider.onChanged!(4.5);
    await tester.pump();
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('맛집 추가 화면에서도 별점을 선택할 수 있다', (tester) async {
    final viewModel = MustEatPlaceViewModel(dataSource: _FakeDataSource());
    await tester.pumpWidget(
      MaterialApp(home: PlaceFormPage(viewModel: viewModel)),
    );

    await tester.drag(
      find.byKey(const Key('place_form_scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rating_slider')), findsOneWidget);
    final ratingSlider = tester.widget<Slider>(
      find.byKey(const Key('rating_slider')),
    );
    ratingSlider.onChanged!(4.0);
    await tester.pump();
    expect(find.text('4.0'), findsOneWidget);
  });

  testWidgets('맛집 추가 시 중복 이름과 전화번호, 별점을 검증한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(dataSource: _FakeDataSource());
    await viewModel.loadPlaces();
    await tester.pumpWidget(
      MaterialApp(home: PlaceFormPage(viewModel: viewModel)),
    );

    await tester.ensureVisible(find.byKey(const Key('name_field')));
    await tester.enterText(find.byKey(const Key('name_field')), '삼겹살 집');
    await tester.ensureVisible(find.byKey(const Key('phone_field')));
    await tester.enterText(find.byKey(const Key('phone_field')), '전화번호');
    tester.testTextInput.hide();
    await tester.pump();
    await tester.fling(
      find.byKey(const Key('place_form_scroll')),
      const Offset(0, -1800),
      2500,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save_place_button')));
    await tester.pump();

    expect(find.text('이미 등록된 맛집 이름입니다.'), findsOneWidget);
    expect(find.text('전화번호 형식을 확인해 주세요.'), findsOneWidget);
    expect(find.byKey(const Key('rating_error')), findsOneWidget);
    expect(find.text('별점을 선택해 주세요.'), findsOneWidget);
  });

  testWidgets('맛집 이름을 입력하면 일치하는 카드만 표시한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(dataSource: _FakeDataSource());
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('place_search_field')), '삼겹살');
    await tester.pump();

    expect(find.text('2곳'), findsOneWidget);
    expect(find.text('삼겹살 집'), findsOneWidget);
    expect(find.text('돈까스 집'), findsNothing);

    await tester.enterText(find.byKey(const Key('place_search_field')), '없는집');
    await tester.pump();

    expect(find.text("'없는집'에 해당하는 맛집이 없습니다."), findsOneWidget);
  });

  testWidgets('저장한 맛집이 없으면 첫 맛집 추가 버튼을 표시한다', (tester) async {
    final dataSource = _FakeDataSource()..places.clear();
    final viewModel = MustEatPlaceViewModel(dataSource: dataSource);
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty_add_place_button')), findsOneWidget);
    expect(find.text('첫 맛집 추가'), findsOneWidget);
  });

  testWidgets('BottomSheet에서 선택한 기준으로 맛집 목록을 정렬한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(
      dataSource: _FakeDataSource(),
      locationDataSource: const _FakeLocationDataSource(),
    );
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    expect(viewModel.filteredPlaces.first.name, '돈까스 집');

    await tester.tap(find.byKey(const Key('sort_button')));
    await tester.pumpAndSettle();
    expect(find.text('최근 등록순'), findsOneWidget);
    expect(find.text('이름순'), findsOneWidget);
    expect(find.text('별점 높은 순'), findsOneWidget);
    expect(find.text('즐겨찾기 우선순'), findsOneWidget);
    expect(find.text('가까운 거리순'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sort_option_name')));
    await tester.pumpAndSettle();
    expect(viewModel.filteredPlaces.first.name, '돈까스 집');

    await viewModel.setSortOption(PlaceSortOption.rating);
    expect(viewModel.filteredPlaces.first.name, '삼겹살 집');

    await viewModel.setSortOption(PlaceSortOption.favorite);
    expect(viewModel.filteredPlaces.first.name, '삼겹살 집');

    await viewModel.setSortOption(PlaceSortOption.distance);
    expect(viewModel.filteredPlaces.first.name, '돈까스 집');
  });

  testWidgets('전체 지도에서 모든 맛집을 표시하고 상세 화면을 연다', (tester) async {
    final viewModel = MustEatPlaceViewModel(
      dataSource: _FakeDataSource(),
      locationDataSource: const _FakeLocationDataSource(),
    );
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('map_navigation')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('all_places_map')), findsOneWidget);
    expect(find.byKey(const Key('add_place_button')), findsNothing);
    expect(find.byKey(const Key('place_marker_1')), findsOneWidget);
    expect(find.byKey(const Key('place_marker_2')), findsOneWidget);
    expect(
      find.byKey(const Key('all_map_current_location_marker')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('place_marker_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('map_marker_preview')), findsOneWidget);
    expect(find.text('삼겹살 집'), findsOneWidget);
    expect(find.text('한식'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(
      find.text(viewModel.distanceLabel(viewModel.places.first)!),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map_place_detail_sheet')), findsNothing);

    await tester.tap(find.byKey(const Key('map_marker_preview_detail')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('map_place_detail_sheet')), findsOneWidget);
  });

  testWidgets('홈에서 선택한 분류의 맛집만 표시한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(dataSource: _FakeDataSource());
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('양식 1').first);
    await tester.pumpAndSettle();

    expect(find.text('1곳'), findsOneWidget);
    expect(find.text('삼겹살 집'), findsNothing);
    expect(find.text('돈까스 집'), findsOneWidget);
  });

  testWidgets('즐겨찾기 필터를 누르면 별표 맛집만 표시한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(dataSource: _FakeDataSource());
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favorite_filter_button')));
    await tester.pumpAndSettle();

    expect(find.text('삼겹살 집'), findsOneWidget);
    expect(find.text('돈까스 집'), findsNothing);
  });

  testWidgets('카드의 별 버튼을 누르면 즐겨찾기 상태가 저장된다', (tester) async {
    final dataSource = _FakeDataSource();
    final viewModel = MustEatPlaceViewModel(dataSource: dataSource);
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favorite_2')));
    await tester.pumpAndSettle();

    expect(dataSource.places.last.isFavorite, isTrue);
  });

  testWidgets('맛집 삭제 후 SnackBar에서 실행 취소하면 목록을 복원한다', (tester) async {
    final dataSource = _FakeDataSource();
    final viewModel = MustEatPlaceViewModel(
      dataSource: dataSource,
      locationDataSource: const _FakeLocationDataSource(),
    );
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('삼겹살 집'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('삼겹살 집'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_place_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete_button')));
    await tester.pumpAndSettle();

    expect(dataSource.places.any((place) => place.seq == 1), isFalse);
    expect(find.byKey(const Key('undo_delete_button')), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).duration,
      const Duration(seconds: 3),
    );

    await tester.tap(find.byKey(const Key('undo_delete_button')));
    await tester.pumpAndSettle();

    expect(dataSource.places.any((place) => place.seq == 1), isTrue);
    expect(find.text('삼겹살 집'), findsOneWidget);
  });

  testWidgets('카드를 누르면 지도와 상세 정보가 있는 BottomSheet를 표시한다', (tester) async {
    final viewModel = MustEatPlaceViewModel(
      dataSource: _FakeDataSource(),
      locationDataSource: const _FakeLocationDataSource(),
    );
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('삼겹살 집'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삼겹살 집'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place_detail_sheet')), findsOneWidget);
    expect(find.byKey(const Key('detail_map')), findsOneWidget);
    expect(find.text('삼겹살 집'), findsWidgets);

    final detailScroll = find.byKey(const Key('detail_scroll'));
    final scrollable = find.descendant(
      of: detailScroll,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('detail_rating')),
      180,
      scrollable: scrollable,
    );
    expect(find.byKey(const Key('detail_rating')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('detail_address')),
      100,
      scrollable: scrollable,
    );
    expect(find.byKey(const Key('detail_address')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('detail_address')),
        matching: find.text('서울특별시 성동구 연무장길 33'),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('detail_distance')),
      100,
      scrollable: scrollable,
    );
    expect(find.byKey(const Key('detail_distance')), findsOneWidget);
    expect(find.byKey(const Key('call_place_button')), findsOneWidget);
    expect(find.byKey(const Key('directions_button')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('삼겹살 1인분 15,000원'),
      180,
      scrollable: scrollable,
    );
    expect(find.text('삼겹살 1인분 15,000원'), findsOneWidget);
  });

  testWidgets('사용자 설정에서 테마와 카테고리 화면을 각각 관리한다', (tester) async {
    final dataSource = _FakeDataSource();
    final viewModel = MustEatPlaceViewModel(dataSource: dataSource);
    await tester.pumpWidget(MaterialApp(home: Home(viewModel: viewModel)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_navigation')));
    await tester.pumpAndSettle();

    expect(find.text('사용자 설정'), findsWidgets);
    expect(find.text('화면 및 테마'), findsOneWidget);
    expect(find.text('카테고리 관리'), findsOneWidget);
    expect(find.text('데이터 관리'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme_settings_button')));
    await tester.pumpAndSettle();

    expect(find.text('화면 모드'), findsOneWidget);
    expect(find.byKey(const Key('dark_mode_switch')), findsOneWidget);

    await tester.tap(find.byKey(const Key('dark_mode_switch')));
    await tester.tap(find.byKey(const Key('theme_color_lavender')));
    await tester.pumpAndSettle();

    expect(dataSource.preferences.isDarkMode, isTrue);
    expect(dataSource.preferences.themeColor, AppThemeColor.lavender);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('data_management_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('export_backup_button')), findsOneWidget);
    expect(find.byKey(const Key('restore_backup_button')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category_settings_button')));
    await tester.pumpAndSettle();

    expect(find.text('카테고리 관리'), findsWidgets);

    await tester.enterText(find.byKey(const Key('category_name_field')), '카페');
    await tester.tap(find.byKey(const Key('add_category_button')));
    await tester.pumpAndSettle();

    expect(find.text('카페'), findsOneWidget);

    final deleteCategoryButton = find.byKey(const Key('delete_category_카페'));
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(deleteCategoryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제').last);
    await tester.pumpAndSettle();

    expect(find.text('카페'), findsNothing);
  });
}

/// 플랫폼 SQLite 없이 ViewModel의 데이터 흐름을 검증하는 가짜 저장소다.
class _FakeDataSource
    implements MustEatPlaceDataSource, AppSettingsDataSource, BackupDataSource {
  final categories = <String>['한식', '중식', '일식', '양식'];

  AppPreferences preferences = const AppPreferences();

  final places = <MustEatPlace>[
    MustEatPlace(
      seq: 1,
      name: '삼겹살 집',
      category: '한식',
      phone: '1111-2222',
      menu: '삼겹살 1인분 15,000원',
      lat: 37.494697,
      lng: 127.03008,
      address: '서울특별시 성동구 연무장길 33',
      estimate: '맛있어요',
      initDate: DateTime(2026, 8, 27),
      isFavorite: true,
      rating: 4.5,
    ),
    MustEatPlace(
      seq: 2,
      name: '돈까스 집',
      category: '양식',
      phone: '1234-5678',
      lat: 37.5,
      lng: 127.04,
      estimate: '바삭해요',
      initDate: DateTime(2026, 8, 27),
      rating: 3.8,
    ),
  ];

  @override
  Future<void> delete(int seq) async {
    places.removeWhere((place) => place.seq == seq);
  }

  @override
  Future<void> deleteCategory(String name) async {
    if (places.any((place) => place.category == name)) {
      throw StateError('사용 중인 카테고리는 삭제할 수 없습니다.');
    }
    categories.remove(name);
  }

  @override
  Future<List<MustEatPlace>> findAll() async => List.of(places);

  @override
  Future<List<String>> findCategories() async => List.of(categories);

  @override
  Future<AppPreferences> findPreferences() async => preferences;

  @override
  Future<AppBackup> createBackup() async {
    return AppBackup(
      places: List.of(places),
      categories: List.of(categories),
      preferences: preferences,
      createdAt: DateTime(2026, 8, 28),
    );
  }

  @override
  Future<void> insert(MustEatPlace place) async => places.add(place);

  @override
  Future<void> insertCategory(String name) async => categories.add(name);

  @override
  Future<void> saveDarkMode(bool enabled) async {
    preferences = AppPreferences(
      isDarkMode: enabled,
      themeColor: preferences.themeColor,
    );
  }

  @override
  Future<void> saveThemeColor(AppThemeColor color) async {
    preferences = AppPreferences(
      isDarkMode: preferences.isDarkMode,
      themeColor: color,
    );
  }

  @override
  Future<void> restoreBackup(AppBackup backup) async {
    places
      ..clear()
      ..addAll(backup.places);
    categories
      ..clear()
      ..addAll(backup.categories);
    preferences = backup.preferences;
  }

  @override
  Future<void> update(MustEatPlace place) async {
    final index = places.indexWhere((item) => item.seq == place.seq);
    places[index] = place;
  }
}

/// 가까운 거리순 테스트에서 돈까스 집 위치를 현재 좌표로 제공한다.
class _FakeLocationDataSource implements LocationDataSource {
  const _FakeLocationDataSource();

  @override
  Future<UserLocation> getCurrentLocation() async {
    return const UserLocation(latitude: 37.5, longitude: 127.04);
  }
}

/// 주소 검색과 좌표 변환 테스트에서 고정된 성수동 위치를 반환합니다.
class _FakeAddressDataSource implements AddressDataSource {
  const _FakeAddressDataSource();

  static const address = '서울특별시 성동구 연무장길 33';

  @override
  Future<AddressLocation> findByAddress(String address) async {
    return const AddressLocation(
      location: UserLocation(latitude: 37.5447, longitude: 127.0558),
      address: _FakeAddressDataSource.address,
    );
  }

  @override
  Future<String> findAddress(double latitude, double longitude) async {
    return address;
  }
}
