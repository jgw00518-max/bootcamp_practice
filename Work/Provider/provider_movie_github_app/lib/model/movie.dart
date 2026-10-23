/// 영화 JSON을 화면에서 사용하는 데이터로 변환한다.
class Movie {
  const Movie({required this.title, required this.image});
  final String title;
  final String image;
  factory Movie.fromJson(Map<String, dynamic> json) =>
      Movie(title: json['title'] as String, image: json['image'] as String);
  Movie copyWith({String? title}) =>
      Movie(title: title ?? this.title, image: image);
}
