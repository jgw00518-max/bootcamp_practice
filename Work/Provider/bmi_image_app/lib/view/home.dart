import 'package:bmi_image_app/vm/calc_bmi_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final heightController = TextEditingController();
  final weightController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final calcBmi = context.watch<CalcBmiModel>();

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
              onPressed: () => calculate(context), 
              child: Text('BMI 계산')
            ),
            Text(calcBmi.result),
            Image.asset(
              calcBmi.bmiImage,
              fit: BoxFit.contain,
            ),
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
  void calculate(BuildContext context){
    if(heightController.text.trim().isEmpty || weightController.text.trim().isEmpty){
      errorSnackBar();
    }else{
      final height = double.tryParse(heightController.text.trim()) ?? 0;
      final weight = double.tryParse(weightController.text.trim()) ?? 0;
      
      context.read<CalcBmiModel>().calculateBMI(height,weight);
    }
  }

  void errorSnackBar(){
    ///
  }

} // class