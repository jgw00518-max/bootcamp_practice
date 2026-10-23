import 'package:collection_view_image_app/detail_flower.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<String> flowerList;

  @override
  void initState() {
    super.initState();
    flowerList = [
      "flower_01.png",
      "flower_02.png",
      "flower_03.png",
      "flower_04.png",
      "flower_05.png",
      "flower_06.png",
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flower Garden"),
        centerTitle: true,
      ),
      body: GridView.builder(
        itemCount: flowerList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ), 
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Get.to(DetailFlower(), arguments: flowerList[index]),
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "images/${flowerList[index]}",
                              width: 110,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            RotationTransition(
                              turns: AlwaysStoppedAnimation(-45/360),
                              child: Text(
                                "All rights reserved!",
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Text(
                      flowerList[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ) 
                  ],
                ),
              ),
            ),
          );          
        },
      ),
    );
  }
}