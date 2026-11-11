import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String imageName;
  late bool lampState;

  @override
  void initState() {
    super.initState();
    imageName = 'images/lamp_on.png';
    lampState = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alert를 이용한 메세지 출력"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageName,
              width: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if(lampState == true){
                          showWarningDialog("현재 램프가 켜진 상태 입니다.");
                        }else{
                          showConfirmDialog(true);
                        }
                      }, 
                      child: Text("켜기"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if(lampState == false){
                          showWarningDialog("현재 램프가 꺼진 상태 입니다.");
                        }else{
                          showConfirmDialog(false);
                        }                    
                      }, 
                      child: Text("끄기"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  void showWarningDialog(String message){
    Get.defaultDialog(
      title: '경고',
      middleText: message,
      actions: [
        TextButton(
          onPressed: () => Get.back(), 
          child: Text('네,알겠습니다.'),
        ),
      ],
    );
  }

void showConfirmDialog(bool targetState) {
    String actionText = targetState ? "켜기" : "끄기";
  
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text("램프 $actionText"),
        message: Text("램프를 ${targetState ? '켜' : '끄'}시겠습니까?"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              lampState = targetState;
              imageName = targetState ? "images/lamp_on.png" : "images/lamp_off.png";
              setState(() {});
              Get.back(); 
            },
            child: const Text("예"),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Get.back(),
            child: const Text("아니오"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
      ),
    );
  }

} // class