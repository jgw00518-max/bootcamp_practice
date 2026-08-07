import 'package:collection_view_label_app/view/detail_hero.dart';
import 'package:collection_view_label_app/view/insert_hero.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QueryHero extends StatefulWidget {
  const QueryHero({super.key});

  @override
  State<QueryHero> createState() => _QueryHeroState();
}

class _QueryHeroState extends State<QueryHero> {
  // Property
  late List<String> heroList;

  @override
  void initState() {
    super.initState();
    heroList = ["유비","관우","장비","조조","여포","초선","손견","장양","손책"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("삼국지 인물"),
        actions: [
          IconButton(
            onPressed: () => Get.to(InsertHero())!.then((value) => rebuildData(value.toString())), 
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: heroList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10
            ), 
          itemBuilder: (context, index) {
            return Container(
              color: Colors.black,
              child: GestureDetector(
                onTap: () => Get.to(DetailHero(), arguments: heroList[index]),
                child: Card(
                  color: Colors.lightBlueAccent,
                  child: Center(
                    child: Text(heroList[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  } // build

  // --- Functions ---
  void rebuildData(String value){
    if(value != ""){
      heroList.add(value);
    }
    setState(() {});
  }



} // class