import 'package:flutter/material.dart';
import 'package:navigator_lamp_app/util/message.dart';
import 'package:navigator_lamp_app/view/controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late TextEditingController textEditingController; // textfield 상태 
  late String lampImage; // 램프 이미지 경로

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    lampImage = "images/lamp_on.png";
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
              Message.contents = textEditingController.text;
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => Controller(),
                ),
              ).then((value) => getData(),);
            }, 
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  labelText: "글자를 입력 하세요"
                ),
              ),
            ),
            Image.asset(
              lampImage,
              width: 150,
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---

  void getData(){
    textEditingController.text = Message.contents;
    lampImage = Message.lampStatus ? "images/lamp_on.png" : "images/lamp_off.png";
    setState(() {});
  }

  
} // class