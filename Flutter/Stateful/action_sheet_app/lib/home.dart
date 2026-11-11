import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Action Sheet"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => actionSheet(), 
          child: Text("Action Sheet "),
        ),
      ),
    );
  } // build

  // --- Functions ---
  void actionSheet(){
    showCupertinoModalPopup(
      context: context, 
      barrierDismissible: false,
      builder: (context) => CupertinoActionSheet(
        title: Text("Title"),
        message: Text("message"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              print("action is pressed");
              Get.back();
            }, 
            child: Text("Action"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
            },
            child: Text("버튼"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(), 
          child: Text("Cancel"),
        ),
      ),
    );
  }



} // class