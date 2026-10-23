// 강사님 예시

import 'dart:async';

import 'package:flutter/material.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  // Property
  late List<String> str;
  late int currentCharacter;
  late String character;


  @override
  void initState() {
    super.initState();
    String data = "대한민국";
    str = data.split(""); // ["대","한","민","국"]
    
    currentCharacter = 0;
    character = str[currentCharacter];

      Timer.periodic(Duration(seconds: 2), (timer) {
      changeCharacter();
    },);
  }

  void changeCharacter(){
    currentCharacter++;
    if(currentCharacter >= str.length){
      currentCharacter = 0;
      character = str[currentCharacter];
    }else{
      character += str[currentCharacter];
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LED 광고'),
      ),
      body: Center(
        child: Text(
          character,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 50,
          ),
        ),
      ),
    );
  }
}