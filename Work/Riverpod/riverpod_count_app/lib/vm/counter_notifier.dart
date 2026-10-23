// 상태 변경 로직 class
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_count_app/vm/counter_state.dart';

class CounterNotifier extends Notifier<CounterState>{
  
  @override
  CounterState build() => const CounterState();

  void increment(){
    state = state.copyWith(
      count: state.count + 1,
      totalClick: state.totalClick + 1
    );
  }

  void decrement(){
    state = state.copyWith(
      count: state.count - 1,
      totalClick: state.totalClick + 1
    );
  }
}
// Notifier 등록 (class 바깥에 있어야함)
final counterProvider = NotifierProvider<CounterNotifier, CounterState>(CounterNotifier.new);