import 'dart:async';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // property
  late bool switchColor;   // Switch 상태
  late String imageName;   // Image file name
  late double angle;       // 회전 각도
  late String switchName;  // Switch label
  late Timer _timer;       // Timer
  late double imageSize; // image 크기

  @override
  void initState() {
    super.initState();
    switchColor = false;
    imageName = "images/lamp_on.png";
    angle = 0;
    switchName = "Yellow";
    imageSize = 250;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {},);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    angle = angle > 360 ? 0 : angle; // build 안에서 변수 선언
    imageSize = imageSize > 400 ? 100 : imageSize;
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: AlwaysStoppedAnimation(angle/360),
              child: SizedBox(
                width: 430,
                height: 430,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                      Image.asset(
                        imageName,
                        height: imageSize,
                        ),
                        Text("Lamp")
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      angle -= 10;
                      setState(() {});
                    }, 
                    child: Text('-10'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      angle += 10;
                      setState(() {});
                    }, 
                    child: Text('+10'),
                  ),
                  ElevatedButton(
                    onPressed: reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                    ),
                    child: Text('Reset'),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(switchName),
                Switch(
                  value: switchColor,
                  onChanged: (value) {
                    switchColor = value;
                    checkLampColor();
                  },
                ),
              ],
            ),
            SizedBox(
              width: 300,
              child: Slider(
                value: angle,
                min: 0,
                max: 360,
                onChanged: (value) {
                  angle = value;
                  setState(() {});
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startTimer, 
                  child: Text("Start Timer"),
                ),
                ElevatedButton(
                  onPressed: stopTimer, 
                  child: Text("Stop Timer"),
                ),
              ],
            ),
            SizedBox(
              width: 300,
              child: Slider( 
                value: imageSize,
                min: 100,
                max: 400,
                onChanged: (value) {
                  imageSize = value;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  void reset(){
    angle = 0;
    imageName = 'images/lamp_on.png';
    switchName = 'Yellow';
    switchColor = false;
    setState(() {});
  }

  void checkLampColor(){
    switchName = switchColor ? "red" : "Yellow";
    imageName = switchColor ? "images/lamp_red.png" : "images/lamp_on.png";
    setState(() {});
  }

  void startTimer(){
    _timer.cancel();
    _timer = Timer.periodic(Duration(microseconds: 10), (timer) {
              angle++;
              imageSize++;
              setState(() {});
    },);
  }

  void stopTimer(){
    _timer.cancel();
    reset();
  }

} // class