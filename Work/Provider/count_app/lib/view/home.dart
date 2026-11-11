import 'package:count_app/vm/counter.dart';
import 'package:count_app/vm/total_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>().count;
    final totalClicks = context.watch<TotalCounter>().count;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider State'),
      ),
      body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('현재 $totalClicks번 클릭 하였습니다. \n'),
                Text('현 카운트의 결과 값은 $counter 입니다.')
              ],
            ),
          ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.read<Counter>().increment();
              context.read<TotalCounter>().clickCount();
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              context.read<Counter>().decrement();
              context.read<TotalCounter>().clickCount();
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}