import 'package:flutter/material.dart';
import 'package:gridview_ex_app/model/animal_list.dart';
import 'package:gridview_ex_app/view/first_page.dart';
import 'package:gridview_ex_app/view/second_page.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  // Property
  late TabController controller; // Tab
  late List<Animal> animalList;  // 동물 list 

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    animalList = [];
    addList();

  }

  void addList(){
    animalList.add(Animal(imagePath: "images/bee.png", animalName: "벌", kind: "곤충", flyExist: true));
    animalList.add(Animal(imagePath: "images/cat.png", animalName: "고양이", kind: "포유류", flyExist: false));
    animalList.add(Animal(imagePath: "images/cow.png", animalName: "소", kind: "포유류", flyExist: false));
    animalList.add(Animal(imagePath: "images/dog.png", animalName: "강아지", kind: "포유류", flyExist: false));
    animalList.add(Animal(imagePath: "images/fox.png", animalName: "여우", kind: "포유류", flyExist: false));
    animalList.add(Animal(imagePath: "images/monkey.png", animalName: "원숭이", kind: "영장류", flyExist: false));
    animalList.add(Animal(imagePath: "images/pig.png", animalName: "돼지", kind: "포유류", flyExist: false));
    animalList.add(Animal(imagePath: "images/wolf.png", animalName: "늑대", kind: "포유류", flyExist: false));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text("ListView Test"),
            Text(
              "전체 길이 : ${animalList.length}",
              style: TextStyle(
                fontSize: 12
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: controller,
          indicatorColor: Colors.red,
          tabs: [
            Tab(
              text: "Table",
              icon: Icon(
                Icons.reorder,
                color: Colors.amber
              )
            ),
            Tab(
              text: "Insert",
              icon: Icon(
                Icons.extension,
                color: Colors.green
              )
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          FirstPage(list: animalList),
          SecondPage(
            list: animalList,
            controller: controller,
            onChangeCount: () {
              setState(() {});
            }
            )
        ]
      ),
    );
  }
}