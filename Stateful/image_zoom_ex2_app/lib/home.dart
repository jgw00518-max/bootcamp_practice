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
  late bool _lampColorSwitch;     // lamp의 색깔 상태 / false: red, true: yellow
  late String _sizeText;
  late String _colorText;
  late String _switchText;

  @override
  void initState() {
    super.initState();
    _lampImage = 'images/lamp_on.png';
    _lampWidth = 150;
    _lampHeight = 300;
    _switch = true;
    _lampSizeSwitch = false;
    _lampColorSwitch = true;
    _sizeText = '전구 확대';
    _colorText = '노란 전구';
    _switchText = '전구 켜기';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image 확대 및 축소"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
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
                      _sizeText,
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      Text(
                        _switchText,
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
                ),
                Column(
                  children: [
                    Text(
                      _colorText,
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Switch(
                      value: _lampColorSwitch,
                      onChanged: (value) {
                        _lampColorSwitch = value;
                        decisionColor();
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  } // build

  // ---- Function ----

  // 전구 색깔 바꾸기
  void decisionColor(){
    _colorText = _lampColorSwitch ? '노란 전구' : '빨간 전구';
    if (_switch) {
      _lampImage = _lampColorSwitch ? 'images/lamp_on.png' : 'images/lamp_red.png';
    }
    setState(() {});
  }

  // 전구 ON/OFF
  void decisionOnOff(){
    if(_switch){
      _lampImage = _lampColorSwitch ? 'images/lamp_on.png' : 'images/lamp_red.png';
      _switchText = '전구 끄기';
    }else{
      _lampImage = 'images/lamp_off.png';
      _switchText = '전구 켜기';
    }

    setState(() {});
  }

  // 전구 크기 조절
  void decisionLampSize(){
    if(_lampSizeSwitch){    // 현재 이미지가 작은 이미지 일 경우
      _lampWidth = 300;
      _lampHeight = 600;
      _sizeText = '전구 축소';
    }else{            // 현재 이미지가 큰 이미지 일 경우
      _lampWidth = 150;
      _lampHeight = 300;
      _sizeText = '전구 확대';
    }
    setState(() {});
  }


} // class