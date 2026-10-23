import 'dart:convert';

import 'app_preferences.dart';
import 'must_eat_place.dart';

/// 맛집, 카테고리, 화면 설정을 하나의 JSON 파일로 옮기기 위한 스냅샷이다.
class AppBackup {
  const AppBackup({
    required this.places,
    required this.categories,
    required this.preferences,
    required this.createdAt,
  });

  static const int schemaVersion = 1;

  final List<MustEatPlace> places;
  final List<String> categories;
  final AppPreferences preferences;
  final DateTime createdAt;

  /// 이미지 바이트까지 Base64로 변환해 사람이 확인 가능한 JSON 문자열을 만든다.
  String toJsonString() {
    final json = {
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toIso8601String(),
      'categories': categories,
      'preferences': {
        'darkMode': preferences.isDarkMode,
        'themeColor': preferences.themeColor.name,
      },
      'places': places.map(_placeToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// JSON 구조와 버전을 검증하고 앱에서 저장할 수 있는 모델로 복원한다.
  factory AppBackup.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) throw const FormatException('올바른 백업 파일이 아닙니다.');
    final json = Map<String, Object?>.from(decoded);
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('지원하지 않는 백업 파일 버전입니다.');
    }

    final rawCategories = json['categories'];
    final rawPlaces = json['places'];
    final rawPreferences = json['preferences'];
    if (rawCategories is! List ||
        rawPlaces is! List ||
        rawPreferences is! Map) {
      throw const FormatException('백업 파일에 필요한 데이터가 없습니다.');
    }

    final categories = rawCategories.map((value) => value.toString()).toList();
    if (categories.isEmpty) {
      throw const FormatException('카테고리가 없는 백업 파일은 복원할 수 없습니다.');
    }
    final preferenceMap = Map<String, Object?>.from(rawPreferences);
    return AppBackup(
      places: rawPlaces.map((value) {
        if (value is! Map) throw const FormatException('맛집 데이터 형식이 잘못되었습니다.');
        return _placeFromJson(Map<String, Object?>.from(value));
      }).toList(),
      categories: categories,
      preferences: AppPreferences(
        isDarkMode: preferenceMap['darkMode'] == true,
        themeColor: AppThemeColor.fromName(
          preferenceMap['themeColor'] as String?,
        ),
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, Object?> _placeToJson(MustEatPlace place) {
    return {
      ...place.toMap(),
      'image': place.image == null ? null : base64Encode(place.image!),
    };
  }

  static MustEatPlace _placeFromJson(Map<String, Object?> json) {
    final encodedImage = json['image'];
    return MustEatPlace.fromMap({
      ...json,
      'image': encodedImage is String && encodedImage.isNotEmpty
          ? base64Decode(encodedImage)
          : null,
    });
  }
}
