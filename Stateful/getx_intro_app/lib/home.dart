import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_intro_app/second_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text("GetX"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Navigation"),
            ElevatedButton(
              onPressed: () => Get.to(SecondPage()), 
              child: Text("Get.to() : 화면 이동"),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/third'), 
              child: Text("Get.toNamed() : 특정 화면으로 이동 "),
            ),
            Divider(
              thickness: 0.5,
              color: Colors.black,
            ),
            Text("Snack Bar"),
            ElevatedButton(
              onPressed: () => buttonSnack(), 
              child: Text("SnackBar"),
            ),
            Text("Dialog"),
            ElevatedButton(
              onPressed: () => buttonDialog(), 
              child: Text("Dialog"),
            ),
            Divider(
              thickness: 0.5,
              color: Colors.black,
            ),
            Text("Bottom Sheet"),
            ElevatedButton(
              onPressed: () => buttonBottomSheet(), 
              child: Text("Bottom Sheet"),
            ),
            Divider(
              thickness: 0.5,
              color: Colors.black,
            ),
            Text("Screen Transition"),
            ElevatedButton(
              onPressed: () {
                Get.to(
                  SecondPage(),
                  transition: Transition.zoom,
                  duration: Duration(seconds: 2)
                );
              }, 
              child: Text("Screen Transition : Get.to()"),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/third2'), 
              child: Text("Screen Transition : Get.toNamed()"),
            ),
            Divider(
              thickness: 0.5,
              color: Colors.black,
            ),
            Text("Navigation & Arguments"),
            ElevatedButton(
              onPressed: () => Get.to(
                SecondPage(),
                arguments: "First"
              ), 
              child: Text("Get.to() : Single Data"),
            ),
            ElevatedButton(
              onPressed: () => Get.to(
                SecondPage(),
                arguments: ["First", "Second"],
              ), 
              child: Text("Get.to() : Multiple Data"),
            ),
            ElevatedButton(
              onPressed: () async{
                var returnValue = await Get.to(SecondPage());
                Get.snackbar("Return Value", returnValue);
              }, 
              child: Text("Get.to() : Return Argument"),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  void buttonSnack(){
    Get.snackbar(
      "SnackBar", // Title
      "Message",  // Message
      snackPosition: SnackPosition.TOP, // SnackBar 나오는 위치 (top, bottom)
      duration: Duration(seconds: 2),
      backgroundColor: Colors.red,
      colorText: Colors.white
    );
  }

  void buttonDialog(){
    Get.defaultDialog(
      title: "Dialog",
      middleText: "Message",
      backgroundColor: Colors.amberAccent,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () => Get.back(), 
          child: Text("Exit"),
        ),
      ]
    );
  }

  void buttonBottomSheet(){
    Get.bottomSheet(
      Container(
        width: 500,
        height: 300,
        color: Colors.amberAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("text Line1"),
            Text("text Line2"),
            ElevatedButton(
              onPressed: () => Get.back(), 
              child: Text("Exit"),
            ),
          ],
        ),
      )
    );
  }

  
} // class