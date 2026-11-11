import 'dart:async';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late List<String> textList;
  late String changeText;
  late int textIndex;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    textList = '대한민국'.split('');
    changeText = '';
    textIndex = 0;

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  updateText();
  },);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void updateText(){
    if(textIndex < textList.length){
      changeText += textList[textIndex];
      textIndex++;
    }else{
      changeText = textList[0];
      textIndex = 1;
    }
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LED 광고'),
        backgroundColor: Colors.grey,
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              changeText,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}