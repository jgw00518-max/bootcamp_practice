import 'package:bmi_image_app/vm/calc_bmi_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  final calcBmi = Get.find<CalcBmiModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI 계산기'),
      ),
      body: Center(
        child: Column(
          children: [
            buildInputTextField('신장을 입력하세요(cm)', heightController),
            buildInputTextField('몸무게를 입력하세요(kg)', weightController),
            ElevatedButton(
              onPressed: () => calculate(), 
              child: Text('BMI 계산')
            ),
            Obx(
              () => Text(calcBmi.result.value),
            ),
            Obx(
              () => Image.asset(
                calcBmi.bmiImage.value,
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
      ),
    );
  } // build

  // --- Widgets ---
  Widget buildInputTextField(String label, TextEditingController controller){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label
      ),
      keyboardType: TextInputType.number,
    );
  }

  // --- Functions ---
  void calculate(){
    if(heightController.text.trim().isEmpty || weightController.text.trim().isEmpty){
      errorSnackBar();
    }else{
      calcBmi.height.value = double.tryParse(heightController.text.trim()) ?? 0;
      calcBmi.weight.value = double.tryParse(weightController.text.trim()) ?? 0;
      calcBmi.calculateBMI();
    }
  }

  void errorSnackBar(){
    ///
  }

} // class