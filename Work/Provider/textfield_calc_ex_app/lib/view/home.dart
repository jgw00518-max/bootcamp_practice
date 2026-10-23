import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textfield_calc_ex_app/vm/calc_model.dart';

class Home extends StatelessWidget {
  Home({super.key});

  // Property
  final num1Controller = TextEditingController();
  final num2Controller = TextEditingController();
  final addController = TextEditingController();
  final subController = TextEditingController();
  final mulController = TextEditingController();
  final divController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalcModel>();

    // 결과 텍스트 갱신
    addController.text = calc.addResult.toString();
    subController.text = calc.subResult.toString();
    mulController.text = calc.mulResult.toString();
    divController.text = calc.divResult.toStringAsFixed(3);

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
                      onPressed: () => calcAction(context),
                      child: Text('계산하기')
                    ),
                    ElevatedButton(
                      onPressed: () => removeAction(context),
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
  void calcAction(BuildContext context){
    if(num1Controller.text.trim().isEmpty || num2Controller.text.trim().isEmpty){
      errorSnackBar(context);
      return;
    }

    final num1 = int.tryParse(num1Controller.text.trim()) ?? 0;
    final num2 = int.tryParse(num2Controller.text.trim()) ?? 0;

    context.read<CalcModel>().calculate(num1, num2);
  }

  void removeAction(BuildContext context){
    num1Controller.clear();
    num2Controller.clear();

    context.read<CalcModel>().clear();
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