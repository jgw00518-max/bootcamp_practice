/// 홈 목록에서 사용할 정렬 기준과 사용자에게 표시할 이름이다.
enum PlaceSortOption {
  newest('최근 등록순'),
  name('이름순'),
  rating('별점 높은 순'),
  favorite('즐겨찾기 우선순'),
  distance('가까운 거리순');

  const PlaceSortOption(this.label);

  final String label;
}
