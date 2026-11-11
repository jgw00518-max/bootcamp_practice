import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late String _lampImage;         // Image file name
  late double _lampWidth;         // Image width
  late double _lampHeight;        // Image height
  late bool _switch;              // Switch 켜짐 상태
  late bool _lampSizeSwitch;      // 화면의 lamp 크기 상태 / false: 작은 이미지, true: 큰 이미지

  @override
  void initState() {
    super.initState();
    _lampImage = 'images/lamp_on.png';
    _lampWidth = 150;
    _lampHeight = 300;
    _switch = true;
    _lampSizeSwitch = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image 확대 및 축소"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 330,
              height: 630,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _lampImage,
                    width: _lampWidth,
                    height: _lampHeight,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '전구 확대',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Switch(
                      value: _lampSizeSwitch, 
                      onChanged: (value) {
                        _lampSizeSwitch = value;
                        decisionLampSize();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Column(
                    children: [
                      const Text(
                        '전구 스위치',
                        style: TextStyle(
                          fontSize: 10
                        ),
                      ),
                      Switch(
                        value: _switch, 
                        onChanged: (value) {
                          _switch = value;
                          decisionOnOff();
                        },
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  } // build

  // ---- Function ----
  void decisionOnOff(){
    _lampImage = _switch ? 'images/lamp_on.png' : 'images/lamp_off.png';
    setState(() {});
  }

  void decisionLampSize(){
    if(_lampSizeSwitch){    // 현재 이미지가 작은 이미지 일 경우
      _lampWidth = 300;
      _lampHeight = 600;
    }else{            // 현재 이미지가 큰 이미지 일 경우
      _lampWidth = 150;
      _lampHeight = 300;
    }
    setState(() {});
  }


} // class