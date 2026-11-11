import 'package:flutter/material.dart';
import 'package:navigator_tabbar_ex_app/model/animal_list.dart';
import 'package:navigator_tabbar_ex_app/view/first_page.dart';
import 'package:navigator_tabbar_ex_app/view/second_page.dart';

class Homebar extends StatefulWidget {
  const Homebar({super.key});

  @override
  State<Homebar> createState() => _HomebarState();
}

class _HomebarState extends State<Homebar> with SingleTickerProviderStateMixin{
  // property
  late TabController controller;  // tab
  late List<Animal> animalList;   // 동물 리스트
  
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    animalList = [];
    addList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ListView Test'),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          FirstPage(list: animalList,),
          SecondPage(list: animalList,)
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: controller,
        tabs: [
          Tab(
            icon: Icon(
              Icons.looks_one,
              color: Colors.blue,
            ),
          ),
          Tab(
            icon: Icon(
              Icons.looks_two,
            ),
          ),
        ],
      ),
    );
  }
}