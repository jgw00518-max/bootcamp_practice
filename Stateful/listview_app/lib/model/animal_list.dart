class AnimalList {
  // Property
  String imagePath;
  String typeList; // 동물 이름 (예: 벌, 강아지)
  String kind;     // 동물 분류 (예: 곤충, 포유류)


  // Constructor
  AnimalList(
    {
      required this.imagePath,
      required this.typeList,
      required this.kind,

    }
  );
}