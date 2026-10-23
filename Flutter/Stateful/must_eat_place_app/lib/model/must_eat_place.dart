import 'dart:typed_data';

/// 맛집 한 건의 화면 데이터와 SQLite 행 변환을 담당한다.
class MustEatPlace {
  /// 추가·수정 화면과 홈 필터에서 공통으로 사용하는 음식 분류다.
  static const List<String> categories = ['한식', '중식', '일식', '양식'];

  const MustEatPlace({
    this.seq,
    required this.name,
    required this.category,
    required this.phone,
    required this.lat,
    required this.lng,
    this.image,
    required this.estimate,
    required this.initDate,
    this.isFavorite = false,
    this.menu = '',
    this.rating = 0,
    this.address = '',
  });

  /// SQLite가 자동 생성하는 기본 키이며, 저장 전 새 객체에서는 null이다.
  final int? seq;

  /// 목록과 입력 화면에 표시되는 맛집 명칭이다.
  final String name;

  /// 맛집을 한식·중식·일식·양식으로 구분하는 분류 값이다.
  final String category;

  /// 맛집에 연락할 수 있는 전화번호 문자열이다.
  final String phone;

  /// 지도 마커의 남북 위치를 결정하는 위도 값이다.
  final double lat;

  /// 지도 마커의 동서 위치를 결정하는 경도 값이다.
  final double lng;

  /// 갤러리에서 읽어 SQLite BLOB과 화면 미리보기에 사용하는 이미지 바이트다.
  final Uint8List? image;

  /// 사용자가 최대 50자로 작성하는 맛집 평가다.
  final String estimate;

  /// 최초 등록 시각이며 수정할 때도 기존 값을 유지한다.
  final DateTime initDate;

  /// 사용자가 즐겨찾기로 지정했는지를 나타내며 SQLite에는 0 또는 1로 저장한다.
  final bool isFavorite;

  /// 상세 화면에서 확인할 수 있는 대표 메뉴 또는 메뉴 설명이다.
  final String menu;

  /// 사용자가 0.5 단위로 남긴 1.0~5.0 별점이며 0은 미등록 상태다.
  final double rating;

  /// 지도에서 변환하거나 검색한 사람이 읽을 수 있는 맛집 주소다.
  final String address;

  /// SQLite 조회 결과를 앱 모델로 변환한다.
  factory MustEatPlace.fromMap(Map<String, Object?> map) {
    return MustEatPlace(
      seq: map['seq'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      phone: map['phone'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      image: map['image'] as Uint8List?,
      estimate: map['estimate'] as String,
      initDate: DateTime.parse(map['initdate'] as String),
      isFavorite: (map['favorite'] as int? ?? 0) == 1,
      menu: map['menu'] as String? ?? '',
      rating: (map['rating'] as num? ?? 0).toDouble(),
      address: map['address'] as String? ?? '',
    );
  }

  /// 모델을 SQLite가 저장할 수 있는 열 값으로 변환한다.
  Map<String, Object?> toMap() {
    return {
      if (seq != null) 'seq': seq,
      'name': name,
      'category': category,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'image': image,
      'estimate': estimate,
      'initdate': initDate.toIso8601String(),
      'favorite': isFavorite ? 1 : 0,
      'menu': menu,
      'rating': rating,
      'address': address,
    };
  }

  /// 일부 값만 바꾼 새 모델을 만들어 불변 데이터의 상태 변경을 안전하게 처리한다.
  MustEatPlace copyWith({bool? isFavorite, double? rating}) {
    return MustEatPlace(
      seq: seq,
      name: name,
      category: category,
      phone: phone,
      lat: lat,
      lng: lng,
      image: image,
      estimate: estimate,
      initDate: initDate,
      isFavorite: isFavorite ?? this.isFavorite,
      menu: menu,
      rating: rating ?? this.rating,
      address: address,
    );
  }
}
