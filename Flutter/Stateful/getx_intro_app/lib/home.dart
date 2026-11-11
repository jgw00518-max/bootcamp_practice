import 'package:flutter/cupertino.dart';
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
    final TextEditingController textController = TextEditingController();
    DateTime selectedTime = DateTime.now();

    Get.defaultDialog(
      title: "할 일 추가",
      backgroundColor: Colors.amberAccent,
      barrierDismissible: false,
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: "할 일을 입력하세요",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "시간: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => Container(
                            height: 250,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.grey[200],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CupertinoButton(
                                        child: const Text("완료"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.time,
                                    initialDateTime: selectedTime,
                                    onDateTimeChanged: (DateTime newTime) {
                                      setDialogState(() {
                                        selectedTime = newTime;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text("시간 선택"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 입력값 확인 테스트용
            print("입력한 메모: ${textController.text}");
            print("선택한 시간: ${selectedTime.hour}:${selectedTime.minute}");
            Get.back();
          }, 
          child: const Text("확인"),
        ),
        TextButton(
          onPressed: () => Get.back(), 
          child: const Text("Exit"),
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