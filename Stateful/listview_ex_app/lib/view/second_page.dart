import 'package:flutter/material.dart';
import 'package:listview_ex_app/model/animal_list.dart';

class SecondPage extends StatefulWidget {
  final List<Animal> list;
  const SecondPage({super.key, required this.list});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // Property
  late TextEditingController nameController; // 동물 이름
  late int _radioValue; // radio 버튼
  late bool flyExist; // 날기 유무
  late String _imagePath; // 이미지 경로
  late String imageName; // 이미지 이름

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    _radioValue = 0;
    flyExist = false;
    _imagePath = "";
    imageName = "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: nameController,
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/cow.png';
                        imageName = '소';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/cow.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/pig.png';
                        imageName = '돼지';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/pig.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/cat.png';
                        imageName = '고양이';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/cat.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/fox.png';
                        imageName = '여우';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/fox.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/dog.png';
                        imageName = '강아지';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/dog.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/monkey.png';
                        imageName = '원숭이';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/monkey.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/wolf.png';
                        imageName = '늑대';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/wolf.png", 
                        width: 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _imagePath = 'images/bee.png';
                        imageName = '벌';
                        setState(() {});
                      },
                      child: Image.asset(
                        "images/bee.png", 
                        width: 80,
                      ),
                    ),
                  ],
                ),
              ),
              Text(imageName),
              ElevatedButton(
                onPressed: () => _showDialog(), 
                child: Text("동물 추가하기"),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // ---- Functions ----
  void _showDialog(){
    var animal = Animal(
      imagePath: _imagePath, 
      animalName: nameController.text.trim(), 
      kind: getKind(_radioValue), 
      flyExist: flyExist,
    );

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(
            "동물 추가하기",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Text(
            "이 동물은 ${animal.animalName} 입니다. \n"
            "또 이 동물의 종류는 ${animal.kind} 입니다. \n"
            "이 동물은 ${animal.flyExist ? '날 수 있습니다.' : '날 수 없습니다.'}\n\n"
            "이 동물을 추가 하시겠습니까?"
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.list.add(animal);
                Navigator.of(context).pop();
              }, 
              child: Text("예"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: Text("아니오"),
            ),
          ],
        );
      },
    );
  }


  String getKind(int radioValue){
    String returnValue = "";
    if(radioValue == 0){
      returnValue = "양서류";
    }else if(radioValue == 1){
      returnValue = "파충류";
    }else{
      returnValue = "포유류";
    }

    return returnValue;
  }

} // class