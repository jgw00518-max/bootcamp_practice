import 'package:flutter/material.dart';

class TotalCounter extends ChangeNotifier{
  int count = 0;

  void clickCount(){
    count++;

    if (count > 30){
      count = 0;
    }
    notifyListeners();
  }
}