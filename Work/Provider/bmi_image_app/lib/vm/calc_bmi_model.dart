import 'package:flutter/material.dart';

class CalcBmiModel extends ChangeNotifier{
  double height = 0.0;
  double weight = 0.0;
  double bmi = 0.0;

  String result = "";
  String resultStr = "";
  String bmiImage = 'images/bmi.png';

  void calculateBMI(double heightCm, double weightKg){
    double h = heightCm / 100;
    double bmi = double.parse((weightKg / (h * h)).toStringAsFixed(1));


    List<double> table = [18.4, 22.9, 24.9, 29.9];
    List<String> labels = ['저체중', '정상체중', '과체중', '비만'];
    List<String> images = [
      'underweight.png',
      'normal.png',
      'risk.png',
      'overweight.png',
    ];
    int index = 0;

    resultStr = '고도비만';
    bmiImage = 'images/obese.png';

    for(double tableData in table){
      if(bmi <=  tableData){
        resultStr = labels[index];
        bmiImage = 'images/${images[index]}';
        break;
      }
      index++;
    }

    result = '귀하의 bmi지수는 $bmi이고\n$resultStr 입니다.';
    notifyListeners();
  }
}