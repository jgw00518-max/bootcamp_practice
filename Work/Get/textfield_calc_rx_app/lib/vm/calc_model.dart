import 'package:get/get.dart';

class CalcModel extends GetxController{
  // Property
  RxInt num1 = 0.obs; // 상태 변수
  RxInt num2 = 0.obs;
  RxInt addResult = 0.obs;
  RxInt subResult = 0.obs;
  RxInt mulResult = 0.obs;
  RxDouble divResult = 0.0.obs;

  void calculate(){
    addResult.value = num1.value + num2.value;
    subResult.value = num1.value - num2.value;
    mulResult.value = num1.value * num2.value;
    divResult.value = num2.value == 0 ? double.infinity : num1.value / num2.value;
  }

  void clear(){
    num1.value = 0;
    num2.value = 0;
    addResult.value = 0;
    subResult.value = 0;
    mulResult.value = 0;
    divResult.value = 0.0;
  }
}