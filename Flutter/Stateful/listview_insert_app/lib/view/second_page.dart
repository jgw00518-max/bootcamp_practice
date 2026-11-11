import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_insert_app/model/animal_list.dart';

class SecondPage extends StatefulWidget {
  final List<Animal> list;
  final TabController controller;
  final Function() onChangeCount;
  

  const SecondPage({super.key, required this.list,required this.controller,required this.onChangeCount,});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late TextEditingController nameController;
  late int _radioValue;
  late bool flyExist;
  late String _imagePath;
  late List<Color> animalColor;

  // [수정] 선택 가능한 고정 이미지 경로 리스트 추가
  final List<String> defaultImages = [
    "images/bee.png",
    "images/cat.png",
    "images/cow.png",
    "images/dog.png",
    "images/fox.png",
    "images/monkey.png",
    "images/pig.png",
    "images/wolf.png",
  ];
  

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    _radioValue = 0;
    flyExist = false;
    _imagePath = "";
    animalColor = [];

    // [수정] widget.list 대신 defaultImages 길이에 맞추어 테두리 색상 초기화
    for(int i = 0; i < defaultImages.length; i++){
      animalColor.add(Colors.yellow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: '등록할 동물 이름을 입력 하세요.'
              ),
              keyboardType: TextInputType.text,
              maxLength: 20,
              maxLines: 1,
            ),
            RadioGroup(
              groupValue: _radioValue,
              onChanged: (value) {
                _radioValue = value!;
                setState(() {});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(value: 0),
                  Text("양서류"),
                  Radio(value: 1),
                  Text("파충류"),
                  Radio(value: 2),
                  Text("포유류"),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("날 수 있나요?"),
                Checkbox(
                  value: flyExist, 
                  onChanged: (value) {
                    flyExist = value!;
                    setState(() {});
                  },
                ),
              ],
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // [수정] itemCount를 고정 이미지 리스트의 길이로 설정
                itemCount: defaultImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => rebuildBorder(index),
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: animalColor[index],
                          width: 2
                        )
                      ),
                      child: Image.asset(
                        // [수정] widget.list[index].imagePath 대신 defaultImages[index] 사용
                        defaultImages[index],
                      ),
                    ),
                  );
                },
              )
            ),
            ElevatedButton(
              onPressed: () => _showDialog(),
              child: Text("동물 추가하기"),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  void rebuildBorder(int index){
    // [수정] defaultImages 길이에 맞춰 테두리 색상 초기화
    for(int i = 0; i < defaultImages.length; i++){
      animalColor[i] = Colors.yellow;
    }

    animalColor[index] = Colors.red;
    // [수정] 선택한 고정 이미지의 경로를 저장
    _imagePath = defaultImages[index];
    
    setState(() {});
  }


  // Dialog
  void _showDialog(){
    Animal animal = Animal(
      imagePath: _imagePath, 
      animalName: nameController.text.trim(), 
      kind: getKind(_radioValue), 
      flyExist: flyExist,
    );

    Get.defaultDialog(
      title: "동물 추가하기",
      middleText: "이 동물은 ${animal.animalName} 입니다.\n"
      "또 동물의 종류는 ${animal.kind} 입니다.\n"
      "이 동물은 ${animal.flyExist ? "날 수 있습니다." : "날 수 없습니다."}\n\n"
      "이 동물을 추가 하시겠습니까?",
      barrierDismissible: false,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                widget.list.add(animal);
                // [수정] 동물이 추가되더라도 선택 가능한 이미지 테두리 리스트(animalColor)에는 영향을 주지 않도록 삭제했습니다.

                // 초기화
                nameController.text = "";
                _radioValue = 0;
                flyExist = false;
                _imagePath = "";

                Get.back();
                
                widget.onChangeCount();

                widget.controller.animateTo(0);
                
              }, 
              child: Text("예"),
            ),
            TextButton(
              onPressed: () => Get.back(), 
              child: Text("아니오"),
            ),
          ],
        )
      ]
    );
  }

  // radio 버튼 Value에 따른 동물 종류 저장
  String getKind(int radioValue){
    String kind = "";
    switch(radioValue){
      case 1:
      kind = "파충류";
      case 2:
      kind = "포유류";
      default:
      kind = "양서류";
    }
    
    return kind;
  }

} // class