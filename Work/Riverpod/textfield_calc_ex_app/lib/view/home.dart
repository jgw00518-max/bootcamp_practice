import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:textfield_calc_ex_app/vm/calc_notifier.dart';


class Home extends ConsumerWidget {
  Home({super.key});

  // Property
  final num1Controller = TextEditingController();
  final num2Controller = TextEditingController();
  final addController = TextEditingController();
  final subController = TextEditingController();
  final mulController = TextEditingController();
  final divController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final calcState = ref.watch(calcProvider);

    // 결과 텍스트 갱신
    addController.text = calcState.addResult.toString();
    subController.text = calcState.subResult.toString();
    mulController.text = calcState.mulResult.toString();
    divController.text = calcState.divResult.toStringAsFixed(3);

    return Scaffold(
      appBar: AppBar(
        title: Text('간단한 계산기'),
      ),
      body: Center(
            child: Column(
              children: [
                buildInputTextField('첫 번째 숫자를 입력하세요', num1Controller),
                buildInputTextField('두 번째 숫자를 입력하세요', num2Controller),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => calcAction(context, ref),
                      child: Text('계산하기')
                    ),
                    ElevatedButton(
                      onPressed: () => removeAction(context, ref),
                      child: Text('지우기')
                    ),
                  ],
                ),
                buildResultTextField('덧셈결과', addController),
                buildResultTextField('뺄셈결과', subController),
                buildResultTextField('곱셈결과', mulController),
                buildResultTextField('나눗셈결과', divController),
              ],
            ),
          ),
    );
  } // build

  // --- Widgets ---
  Widget buildInputTextField(String label, TextEditingController controller){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
  Widget buildResultTextField(String label, TextEditingController controller){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label
        ),
        keyboardType: TextInputType.number,
        readOnly: true,
      ),
    );
  }

  // --- Functions ---
  void calcAction(BuildContext context, WidgetRef ref){
    if(num1Controller.text.trim().isEmpty || num2Controller.text.trim().isEmpty){
      errorSnackBar(context);
      return;
    }

    final num1 = int.tryParse(num1Controller.text.trim()) ?? 0;
    final num2 = int.tryParse(num2Controller.text.trim()) ?? 0;

    ref.read(calcProvider.notifier).calculate(num1, num2);
  }

  void removeAction(BuildContext context, WidgetRef ref){
    num1Controller.clear();
    num2Controller.clear();

    ref.read(calcProvider.notifier).clear();
  }

  void errorSnackBar(BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('숫자를 입력하세요.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      )
    );
  }
} // class