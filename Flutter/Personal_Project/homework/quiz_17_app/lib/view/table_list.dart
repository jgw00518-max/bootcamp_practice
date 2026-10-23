import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quiz_17_app/model/todo_list.dart';
import 'package:quiz_17_app/view/detail_list.dart';

class TableList extends StatefulWidget {
  const TableList({super.key});

  @override
  State<TableList> createState() => _TableListState();
}

class _TableListState extends State<TableList> {
  // property
  late List<TodoList> todoList; 
  final box = GetStorage();
  late String imagePath;
  late String workList;

  @override
  void initState() {
    super.initState();
    todoList = [];
    addData();
  }

  void addData(){
    todoList.add(TodoList(imagePath: "images/cart.png", workList: "책구매"));
    todoList.add(TodoList(imagePath: "images/clock.png", workList: "철수와 약속"));
    todoList.add(TodoList(imagePath: "images/pencil.png", workList: "스터디 준비하기"));
  }

  void loadStorage(){
    imagePath = box.read("p_imagePath");
    workList = box.read("p_workList");

    if (imagePath.isNotEmpty && workList.isNotEmpty) {
      todoList.add(TodoList(imagePath: imagePath, workList: workList));

      box.write("p_imagePath", "");
      box.write("p_workList", "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main View"),
        actions: [
          IconButton(
            // async/await 및 Get.to() 패턴 사용 (AI 도움)
            onPressed: () async {
              await Get.toNamed("/insert");
              loadStorage();
              setState(() {});
            }, 
            icon: const Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              direction: DismissDirection.endToStart,
              key: ValueKey(todoList[index]),
              onDismissed: (direction) {
                todoList.remove(todoList[index]);
                setState(() {});
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Icon(
                  Icons.delete_forever,
                  size: 30,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  // Get.to() 및 arguments 전달 방식 사용
                  Get.to(const DetailList(), arguments: todoList[index]);
                },
                child: SizedBox(
                  height: 100,
                  child: Card(
                    color: index % 2 == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                    child: Row(
                      children: [
                        Image.asset(
                          todoList[index].imagePath,
                        ),
                        Text(
                          "               ${todoList[index].workList}"
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}