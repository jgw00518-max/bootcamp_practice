import 'package:flutter/material.dart';
import 'package:naviagtor_lamp_switch_app/util/message.dart';
import 'package:naviagtor_lamp_switch_app/view/controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late String lampImage; // lamp 이미지

  @override
  void initState() {
    super.initState();
    lampImage = "images/lamp_on.png";
  }

void updateLampImage() {
    if (Message.lampStatus == false) {
      lampImage = "images/lamp_off.png";
    } else if (Message.lampColor) {
      lampImage = "images/lamp_red.png";
    } else {
      lampImage = "images/lamp_on.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main 화면"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Message.lampColor;
              Message.lampStatus;
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => Controller(),
                ),
              ).then((value) {
                updateLampImage();
                setState(() {});
              },);
            }, 
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: Image.asset(
          lampImage,
          width: 150,
        ),
      ),
    );
  }
}