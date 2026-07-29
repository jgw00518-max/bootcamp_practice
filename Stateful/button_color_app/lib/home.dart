import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Property
  late String buttonText; // 버튼의 Text 저장
  late Color buttonColor; // 버튼의 Color 저장
  late bool buttonState;  // 버튼의 횟수 판단

  @override
  void initState() {
    super.initState();
    buttonText = 'Hello';
    buttonColor = Colors.blue;
    buttonState = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change button color & text'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _onClick(),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            minimumSize:const Size(100, 40)
          ), 
          child: Text(buttonText),
        ),
      ),
    );
  } // build

  // Function

  // -------------------------------------------------------
  // Date   : 26.07.29
  // Desc   : 버튼의 Text와 Color 바꾸는 기능
  // Author : me
  // -------------------------------------------------------

  void _onClick() {

    if(buttonState == true){
      buttonText = 'Flutter';
      buttonColor = Colors.amber;
      buttonState = false;
    }else{
      buttonText = 'Hello';
      buttonColor = Colors.blue;
      buttonState = true;
    }
    setState(() {});
  }


} // class