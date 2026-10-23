import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:textfield_calc_ex_app/vm/calc_state.dart';

class CalcNotifier extends Notifier<CalcState>{
  @override
  CalcState build() => const CalcState();

  void calculate(int n1, int n2){
    state = state.copyWith(
      num1: n1,
      num2: n2,
      addResult: n1 + n2,
      subResult: n1 - n2,
      mulResult: n1 * n2,
      divResult: n2 != 0 ? n1 / n2 : 0.0
    );
  }

  void clear(){
    state = const CalcState();
  }
}

final calcProvider = NotifierProvider<CalcNotifier, CalcState>(CalcNotifier.new);