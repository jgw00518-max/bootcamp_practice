/// Pixabay API가 지원하는 이미지 종류다.
enum PixabayImageType {
  photo('photo', '사진'),
  illustration('illustration', '일러스트');

  const PixabayImageType(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// Pixabay API가 지원하는 이미지 방향이다.
enum PixabayOrientation {
  all(null, '전체'),
  horizontal('horizontal', '가로'),
  vertical('vertical', '세로');

  const PixabayOrientation(this.apiValue, this.label);
  final String? apiValue;
  final String label;
}

/// 검색 조건을 묶어 목록 재조회와 페이지 추가 요청에 재사용한다.
class PixabaySearchFilter {
  const PixabaySearchFilter({
    this.imageType = PixabayImageType.photo,
    this.orientation = PixabayOrientation.all,
    this.category,
  });

  final PixabayImageType imageType;
  final PixabayOrientation orientation;
  final String? category;

  PixabaySearchFilter copyWith({
    PixabayImageType? imageType,
    PixabayOrientation? orientation,
    String? category,
    bool clearCategory = false,
  }) => PixabaySearchFilter(
    imageType: imageType ?? this.imageType,
    orientation: orientation ?? this.orientation,
    category: clearCategory ? null : category ?? this.category,
  );
}

/// Pixabay 검색 결과 한 건을 화면에서 사용할 형태로 표현한다.
class PixabayImage {
  const PixabayImage({
    required this.id,
    required this.previewUrl,
    required this.largeImageUrl,
    required this.tags,
    required this.userName,
    required this.likes,
    required this.views,
    required this.downloads,
  });

  final int id;
  final String previewUrl;
  final String largeImageUrl;
  final String tags;
  final String userName;
  final int likes;
  final int views;
  final int downloads;

  /// Pixabay hits 항목을 앱 모델로 변환한다.
  factory PixabayImage.fromJson(Map<String, dynamic> json) => PixabayImage(
    id: json['id'] as int,
    previewUrl: json['webformatURL'] as String,
    largeImageUrl: json['largeImageURL'] as String,
    tags: json['tags'] as String? ?? '',
    userName: json['user'] as String? ?? '알 수 없음',
    likes: json['likes'] as int? ?? 0,
    views: json['views'] as int? ?? 0,
    downloads: json['downloads'] as int? ?? 0,
  );

  /// 즐겨찾기 영속 저장에 필요한 API 호환 형태의 JSON을 만든다.
  Map<String, dynamic> toJson() => {
    'id': id,
    'webformatURL': previewUrl,
    'largeImageURL': largeImageUrl,
    'tags': tags,
    'user': userName,
    'likes': likes,
    'views': views,
    'downloads': downloads,
  };
}

/// 한 페이지의 목록과 추가 페이지 유무 판단용 전체 결과 수다.
class PixabaySearchResult {
  const PixabaySearchResult({required this.images, required this.totalHits});
  final List<PixabayImage> images;
  final int totalHits;
}
