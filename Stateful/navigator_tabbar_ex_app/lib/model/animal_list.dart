class Animal {
  // Property
  String imagePath;  // 이미지 경로
  String animalName; // 동물 이름
  String kind;       // 동물 분류
  bool flyExist;     // 날기 유무

  // Constructor
  Animal(
    {
      required this.imagePath,
      required this.animalName,
      required this.kind,
      required this.flyExist
    }
  );
}