class Movie {
  final String image;
  final String title;

  Movie({required this.image, required this.title});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      image: json['image'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'image': image, 'title': title};
  }
}
