import 'package:flutter/material.dart';
import 'package:listview_app/view/table_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // Property
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
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
        title: const Text("Listview Test"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: TabBarView(
        controller: controller,
        children: [
          const TableList(), // 1번 탭: 동물 리스트 화면
          Container(),       // 2번 탭: 비워둠 (추후 추가용)
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: controller,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.red,
          tabs: const [
            Tab(
              icon: Icon(Icons.looks_one),
            ),
            Tab(
              icon: Icon(Icons.looks_two),
            ),
          ],
        ),
      ),
    );
  }
}