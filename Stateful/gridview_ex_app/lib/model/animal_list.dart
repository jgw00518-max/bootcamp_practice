class Animal{
  String imagePath; // 이미지 경로
  String animalName; // 동물 이름
  String kind;      // 동물 종류
  bool flyExist;    // 비행 유무

  Animal(
    {
      required this.imagePath,
      required this.animalName,
      required this.kind,
      required this.flyExist,
    }
  );
}