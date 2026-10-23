import 'package:flutter/material.dart';

class Counter extends ChangeNotifier{ // extends or with (보통 extends 뒤에 더 추가할게 있을 때 with)
  int count = 0;
  
  void increment(){
    count++;
    notifyListeners();
  }

  void decrement(){
    count--;
    notifyListeners();
  }
}