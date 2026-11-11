import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_count_app/vm/counter_notifier.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Riverpod State'),
      ),
      body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('현재 ${counterState.totalClick} 클릭 하였습니다. \n'),
                Text('현 카운트의 결과 값은 ${counterState.count} 입니다.')
              ],
            ),
          ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              ref.read(counterProvider.notifier).increment();
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              ref.read(counterProvider.notifier).decrement();
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}