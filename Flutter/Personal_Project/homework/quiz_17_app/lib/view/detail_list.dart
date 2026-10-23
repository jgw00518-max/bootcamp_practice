import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_17_app/model/todo_list.dart';

class DetailList extends StatefulWidget {
  const DetailList({super.key});

  @override
  State<DetailList> createState() => _DetailListState();
}

class _DetailListState extends State<DetailList> {
final todo = Get.arguments as TodoList; // as = 타입 캐스팅, 데이터의 타입을 확정짓는 역할(오류 발생 대비) // ai 도움

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail View"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              todo.imagePath,
              width: 100,
            ),
            Text(
              todo.workList,
            ),
          ],
        ),
      ),
    );
  }
}