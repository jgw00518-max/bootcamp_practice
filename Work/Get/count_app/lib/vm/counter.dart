import 'package:get/get.dart';

class Counter extends GetxController{
  // Property
  int count = 0;
  int totalCount = 0;

  void increment(){
    count++;
    update();
  }

  void decrement(){
    count--;
    update();
  }

  void clickCount(){
    totalCount++;
    update();
  }
}