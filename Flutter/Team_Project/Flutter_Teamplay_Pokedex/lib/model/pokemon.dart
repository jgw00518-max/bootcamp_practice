// 포켓몬 모델
class Pokemon {
  // Properties
  int number;     // 도감 번호
  String name;    // 이름
  String image;   // 이미지 경로

  // Constructor
  Pokemon(
    {
    required this.number,
    required this.name,
    required this.image
    }
  );
}