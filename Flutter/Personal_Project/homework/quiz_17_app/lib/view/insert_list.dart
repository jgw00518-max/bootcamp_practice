import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quiz_17_app/model/todo_list.dart';

class InsertList extends StatefulWidget {
  const InsertList({super.key});

  @override
  State<InsertList> createState() => _InsertListState();
}

class _InsertListState extends State<InsertList> {
  late TextEditingController textEditingController; // textField
  int selectedCategory = 0;                         // 선택된 카테고리 인덱스 (0: 구매, 1: 약속, 2: 스터디)
  late List<String> imagePaths;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    imagePaths = [
    "images/cart.png",
    "images/clock.png",
    "images/pencil.png",
    ];
    box.write("p_imagePath", "");
    box.write("p_workList", "");
  }

  void saveStorage() {
    box.write("p_imagePath", imagePaths[selectedCategory]);
    box.write("p_workList", textEditingController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add View"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePaths[selectedCategory],
                  width: 100,
                  height: 100,
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CupertinoPicker(
                    itemExtent: 50,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    // CupertinoPicker의 초기 스크롤 위치를 제어하는 컨트롤러 설정(ai)
                    scrollController: FixedExtentScrollController(
                      // 피커 뷰가 처음 화면에 뜰 때 selectedCategory(기본값 0: 첫 번째 항목) 위치에 휠을 배치(ai)
                      initialItem: selectedCategory,
                    ),
                    onSelectedItemChanged: (value) {
                      selectedCategory = value;
                      setState(() {});
                    },
                    children: List.generate(
                      imagePaths.length,
                      (index) => Center(
                        child: Image.asset(
                          imagePaths[index],
                          width: 35,
                          height: 35,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: '목록을 입력 하세요'
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (textEditingController.text.trim().isEmpty) {
                  Get.snackbar(
                    "경고",
                    "목록을 입력 하세요",
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                saveStorage();
                Get.back(); // result: 새로운 리스트 추가를 위함
              }, 
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  TodoList addList() {
    const List<String> imagePaths = [
      "images/cart.png",
      "images/clock.png",
      "images/pencil.png"
    ];

// 선택된 카테고리 이미지와 입력된 텍스트로 새로운 TodoList 객체 생성 후 반환
    return TodoList(
      imagePath: imagePaths[selectedCategory],
      workList: textEditingController.text.trim(),
    );
  }
} 