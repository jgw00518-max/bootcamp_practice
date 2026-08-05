import 'package:flutter/material.dart';
import 'package:naviagtor_lamp_switch_app/util/message.dart';

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  // property
  late bool colorSwitch; // 색깔 스위치
  late bool statusSwitch; // 상태 스위치

  @override
  void initState() {
    super.initState();
    colorSwitch = Message.lampColor;
    statusSwitch = Message.lampStatus;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("수정화면"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Red"),
                Switch(
                  value: colorSwitch, 
                  onChanged: (value) {
                    colorSwitch = value;
                    setState(() {});
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(statusSwitch ? "ON" : "OFF"),
                  Switch(
                    value: statusSwitch, 
                    onChanged: (value) {
                      statusSwitch = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Message.lampColor = colorSwitch;
                Message.lampStatus = statusSwitch;
                Navigator.pop(context);
              }, 
              child: Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}