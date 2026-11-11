import 'package:flutter/material.dart';
import 'package:listview_app/model/animal_list.dart';

class TableList extends StatefulWidget {
  const TableList({super.key});

  @override
  State<TableList> createState() => _TableListState();
}

class _TableListState extends State<TableList> {
  // Property
  late List<AnimalList> animalList = [];

  @override
  void initState() {
    super.initState();
    animalList = [];
    addData();
  }

  void addData() {
    animalList.add(AnimalList(imagePath: "images/bee.png", typeList: "벌", kind: "곤충"));
    animalList.add(AnimalList(imagePath: "images/cat.png", typeList: "고양이", kind: "포유류"));
    animalList.add(AnimalList(imagePath: "images/cow.png", typeList: "소", kind: "포유류"));
    animalList.add(AnimalList(imagePath: "images/dog.png", typeList: "강아지", kind: "포유류"));
    animalList.add(AnimalList(imagePath: "images/fox.png", typeList: "여우", kind: "포유류"));
    animalList.add(AnimalList(imagePath: "images/monkey.png", typeList: "원숭이", kind: "포유류"));
    animalList.add(AnimalList(imagePath: "images/pig.png", typeList: "돼지", kind: "포유류"));
    animalList.add(AnimalList(imagePath: "images/wolf.png", typeList: "늑대", kind: "포유류"));
  }

  // 동물 클릭 시 얼럿 대화상자(AlertDialog) 표시
  void _showAnimalDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            animalList[index].typeList,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("이 동물은 ${animalList[index].kind} 입니다."),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("종료"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: animalList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              direction: DismissDirection.endToStart,
              key: ValueKey(animalList[index]),
              onDismissed: (direction) {
                animalList.removeAt(index);
                setState(() {});
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete_forever,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  _showAnimalDialog(index);
                },
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Image.asset(
                        animalList[index].imagePath,
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        animalList[index].typeList,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  } // build
} // class