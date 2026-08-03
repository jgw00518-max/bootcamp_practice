import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // property
  late String imageName;
  late bool lampState; // true: 켜짐, false: 꺼짐

  @override
  void initState() {
    super.initState();
    imageName = "images/lamp_on.png";
    lampState = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alert를 이용한 메세지 출력"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
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
                  // 켜기 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (lampState == true) {
                        showWarningDialog("현재 램프가 켜진 상태 입니다.");
                      } else {
                        showLampConfirmDialog(true); // 켜기 동작 전달
                      }
                    },
                    child: const Text("켜기"),
                  ),
                  const SizedBox(width: 10),
                  // 끄기 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (lampState == false) {
                        showWarningDialog("현재 램프가 꺼진 상태 입니다.");
                      } else {
                        showLampConfirmDialog(false); // 끄기 동작 전달
                      }
                    },
                    child: const Text("끄기"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Functions ---

  // 1. 이미 해당 상태일 때 띄우는 경고 다이얼로그 (버튼 1개)
  void showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("경고"),
          content: Text(message),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "네, 알겠습니다.",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

// 2. 램프 상태 변경 확인 다이얼로그 (통합 버전)
void showLampConfirmDialog(bool targetState) {
  // 목표 상태(targetState)에 따른 문구 및 이미지 경로 설정
  final String actionText = targetState ? "켜기" : "끄기";
  final String newImage = targetState ? "images/lamp_on.png" : "images/lamp_off.png";

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("램프 $actionText"),
        content: Text("램프를 ${actionText}시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                lampState = targetState;
                imageName = newImage;
              });
              Navigator.of(context).pop();
            },
            child: const Text("네", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("아니오", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
}