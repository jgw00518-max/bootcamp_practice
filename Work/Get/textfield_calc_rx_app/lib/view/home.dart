import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:textfield_calc_rx_app/vm/calc_model.dart';

class Home extends StatelessWidget {
  Home({super.key});

  // Property
  final num1Controller = TextEditingController();
  final num2Controller = TextEditingController();

  final calc = Get.find<CalcModel>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('간단한 계산기 Using Rx'),
      ),
      body: GetBuilder<CalcModel>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: [
                  buildInputTextField('첫 번째 숫자를 입력하세요', num1Controller),
                  buildInputTextField('두 번째 숫자를 입력하세요', num2Controller),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => calcAction(),
                        child: Text('계산하기')
                      ),
                      ElevatedButton(
                        onPressed: () => removeAction(),
                        child: Text('지우기')
                      ),
                    ],
                  ),
                  buildResultTextField('덧셈결과', calc.addResult),
                  buildResultTextField('뺄셈결과', calc.subResult),
                  buildResultTextField('곱셈결과', calc.mulResult),
                  buildResultTextField('나눗셈결과', calc.divResult, isDiv: true),
                ],
              ),
            ),
          );
        },
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
  Widget buildResultTextField(String label, Rx rxValue, {bool isDiv = false}){
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: TextEditingController(
            text: isDiv ? (rxValue.value as double).toStringAsFixed(3) : rxValue.value.toString()
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: label
          ),
        ),
      ),
    );
  }

  // --- Functions ---
  void calcAction(){
    if(num1Controller.text.trim().isEmpty || num2Controller.text.trim().isEmpty){
      errorSnackBar();
      return;
    }

    calc.num1.value = int.tryParse(num1Controller.text.trim()) ?? 0;
    calc.num2.value = int.tryParse(num2Controller.text.trim()) ?? 0;
    calc.calculate();
  }

  void removeAction(){
    num1Controller.clear();
    num2Controller.clear();

    calc.clear();
  }

  void errorSnackBar(){
    ///
  }
} // class