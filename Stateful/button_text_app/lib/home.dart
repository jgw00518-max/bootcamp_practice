import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late String buttonText; // 버튼의 결과 텍스트
  late bool buttonState; // 버튼의 횟수 판단

  @override
  void initState() {
    super.initState();
    buttonText = 'OFF';
    buttonState = false;
    print("==========initState()를 구동했습니다.===========");
  }

  @override
  Widget build(BuildContext context) {
        print("==========build()를 구동했습니다.===========");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Life Cycle"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _onClick(),
              child: const Text('버튼을 누르세요.'),
              ),
              Text(
                '버튼 상태 : $buttonText'
              )
          ],
        ),
      ),
    );
  } //build

  // --- Function ---
  // -------------------------------------------------------
  // Date   : 26.07.29
  // Desc   : 버튼 상태를 OFF와 ON으로 Toggle한다.
  // Author : me
  // -------------------------------------------------------

  // void _onClick(){

  //   if(buttonState == false) {
  //   buttonText = 'ON';
  //   buttonState = true;
  //   }else{                           // 이런 식으로 기능을 바꿔도 삭제하지 않고 남겨둠
  //   buttonText = 'OFF';
  //   buttonState = false;
  //   }
  //   setState(() {});
  // }


  // -------------------------------------------------------
  // Date   : 26.07.29
  // Desc   : 버튼 상태를 OFF와 ON으로 Toggle한다.
  // Author : me
  // -------------------------------------------------------

  void _onClick(){

    if(buttonState == false) {
      buttonText = 'ON';
      buttonState = true;
    }else{
      buttonText = 'OFF';
      buttonState = false;
    }
    setState(() {});
  }

} // class