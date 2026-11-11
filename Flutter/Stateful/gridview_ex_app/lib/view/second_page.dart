import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gridview_ex_app/model/animal_list.dart';

class SecondPage extends StatefulWidget {
  final List<Animal> list;
  final TabController controller;
  final Function() onChangeCount;

  const SecondPage({
    super.key,
    required this.list,
    required this.controller,
    required this.onChangeCount,
  });

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late TextEditingController nameController;
  late int _radioValue;
  late bool flyExist;
  late String _imagePath;
  late FixedExtentScrollController _pickerController; 

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
    _imagePath = defaultImages[0];
    _pickerController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    nameController.dispose();
    _pickerController.dispose(); 
    super.dispose();
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
              decoration: const InputDecoration(
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
                children: const [
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
                const Text("날 수 있나요?"),
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
              height: 150,
              child: CupertinoPicker(
                scrollController: _pickerController,
                itemExtent: 80,
                onSelectedItemChanged: (int index) {
                    _imagePath = defaultImages[index];
                  setState(() {});
                },
                children: List.generate(
                  defaultImages.length, 
                  (index) => Center(
                    child: Image.asset(
                      defaultImages[index],
                      width: 70,
                      height: 70,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showDialog(),
              child: const Text("동물 추가하기"),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---

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

                // 초기화
                nameController.text = "";
                _radioValue = 0;
                flyExist = false;
                _imagePath = defaultImages[0];
                _pickerController.jumpToItem(0); 

                Get.back();
                
                widget.onChangeCount();

                widget.controller.animateTo(0);
                
              }, 
              child: const Text("예"),
            ),
            TextButton(
              onPressed: () => Get.back(), 
              child: const Text("아니오"),
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
        break;
      case 2:
        kind = "포유류";
        break;
      default:
        kind = "양서류";
    }
    
    return kind;
  }

} // class