import 'package:get/get.dart';

class CalcBmiModel extends GetxController{
  RxDouble height = 0.0.obs;
  RxDouble weight = 0.0.obs;
  RxDouble bmi = 0.0.obs;

  RxString result = "".obs;
  RxString resultStr = "".obs;
  RxString bmiImage = 'images/bmi.png'.obs;


  void calculateBMI(){
    double h = height.value / 100;
    double w = weight.value;
    double bmiValue = w / (h*h);

    bmi.value = double.parse(bmiValue.toStringAsFixed(1));

    List<double> table = [18.4, 22.9, 24.9, 29.9];
    List<String> labels = ['저체중', '정상체중', '과체중', '비만'];
    List<String> images = [
      'underweight.png',
      'normal.png',
      'risk.png',
      'overweight.png',
    ];
    int index = 0;

    resultStr.value = '고도비만';
    bmiImage.value = 'images/obese.png';

    for(double tableData in table){
      if(bmi.value <= tableData){
        resultStr.value = labels[index];
        bmiImage.value = 'images/${images[index]}';
        break;
      }
      index++;
    }

    result.value = '귀하의 bmi지수는 $bmi이고\n$resultStr 입니다.';
  }
}