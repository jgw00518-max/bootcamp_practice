import 'package:flutter/material.dart';

import 'package:tabbar_app/view/first_page.dart';
import 'package:tabbar_app/view/fourth_page.dart';
import 'package:tabbar_app/view/second_page.dart';
import 'package:tabbar_app/view/third_page.dart';



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin {

  // Property
  late TabController controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(
      length: 4,
      vsync: this,
    );
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
        centerTitle: true,
        title: Text('Tab Bar Test'),
      ),

      body: TabBarView(
        controller: controller,
        children: [
          FirstPage(),
          SecondPage(),
          ThirdPage(),
          FourthPage(),
        ],
      ),

      bottomNavigationBar: Container(
        color: Colors.amber,
        height: 80,
        child: TabBar(
          controller: controller,
          labelColor: Colors.blue,
          indicatorColor: Colors.red,

          tabs: [
            Tab(
              icon: Icon(Icons.looks_one),
              text : "One",
            ),
            Tab(
              icon: Icon(Icons.looks_two),
              text : "Two",
            ),
            Tab(
              icon: Icon(Icons.looks_3),
              text : "Three",
            ),
            Tab(
              icon: Icon(Icons.looks_4),
              text : "Four",
            ),
          ],
        ),
      ),
    );
  }
}