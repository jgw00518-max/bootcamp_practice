import 'package:flutter/material.dart';
import 'package:navigator_lamp_app/util/message.dart';

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  // property
  late TextEditingController textEditingController; // textfield 
  late String switchLabel; // 스위치 이름 (ON, OFF)
  late bool switchValue; // 스위치 상태 (true, false)

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.text = Message.contents;

    if(Message.lampStatus){
      switchLabel = 'ON';
      switchValue = true; 
    }else{
      switchLabel = 'OFF';
      switchValue = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("수정화면"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: textEditingController,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(switchLabel),
                Switch(
                  value: switchValue, 
                  onChanged: (value) {
                    switchValue = value;
                    switchLabel = switchValue ? "ON" : "OFF";
                    setState(() {});
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Message.contents = textEditingController.text;
                  Message.lampStatus = switchValue;
                  Navigator.pop(context);
                }, 
                child: Text("OK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}