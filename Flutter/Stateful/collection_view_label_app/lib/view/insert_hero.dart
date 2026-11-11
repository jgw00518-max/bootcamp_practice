import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsertHero extends StatefulWidget {
  const InsertHero({super.key});

  @override
  State<InsertHero> createState() => _InsertHeroState();
}

class _InsertHeroState extends State<InsertHero> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("인물 추가"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "인물을 추가 하세요"
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String resultMessage = "";
                if(nameController.text.trim().isNotEmpty){
                  resultMessage = nameController.text.trim();
                }

                Get.back(result: resultMessage);

              }, 
              child: Text("추가"),
              ),
          ],
        ),
      ),
    );
  }
}