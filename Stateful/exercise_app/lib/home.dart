import 'dart:async';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late TextEditingController textEditingController;
  late TextEditingController num1Controller;
  late String changeText;
  late int textIndex;
  late List<String> textList;
  late Timer _timer;
  


  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    num1Controller = TextEditingController();
    textList = [];
    changeText = '';
    textIndex = 0;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();

  }

  void adText(){
    String input = textEditingController.text.trim();
    
    if (input.isEmpty) return;
    

    textList = input.split(''); // 문자열 분할
    changeText = textList[0];   // 첫 글자
    textIndex = 1;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateText();
    },);

    Navigator.pop(context);

    setState(() {});
  }

  void updateText(){  
    if(textIndex < textList.length){
      changeText += textList[textIndex];
      textIndex++;
    }else{
      changeText = textList[0];
      textIndex = 1;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LED 광고"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              
              accountName: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('            광고 문구를 입력하세요'),
                ],
              ), 
              accountEmail: Text(''),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                )
              )
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 100, 10, 20),
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: '글자를 입력하세요'
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    adText();
                  }, 
                  child: Text('광고문구 생성'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(changeText),
          ],
        ),
      ),
    );
  }
}