import 'package:count_app/vm/counter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Getx State'),
      ),
      body: GetBuilder<Counter>(
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('현재 ${controller.totalCount}번 클릭 하였습니다. \n'),
                Text('현 카운트의 결과 값은 ${controller.count} 입니다.')
              ],
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Get.find<Counter>().increment();
              Get.find<Counter>().clickCount();
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              Get.find<Counter>().decrement();
              Get.find<Counter>().clickCount();
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}