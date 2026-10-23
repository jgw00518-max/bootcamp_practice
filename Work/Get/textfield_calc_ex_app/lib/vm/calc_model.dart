import 'package:get/get.dart';

class CalcModel extends GetxController{
  // Property
  int num1 = 0;
  int num2 = 0;
  int addResult = 0;
  int subResult = 0;
  int mulResult = 0;
  double divResult = 0.0;

  void calculate(int n1, int n2){
    addResult = n1 + n2;
    subResult = n1 - n2;
    mulResult = n1 * n2;
    divResult = n2 != 0 ? n1 / n2 : 0.0;
    update();
  }

  void clear(){
    num1 = 0;
    num2 = 0;
    addResult = 0;
    subResult = 0;
    mulResult = 0;
    divResult = 0;
    update();
  }
}