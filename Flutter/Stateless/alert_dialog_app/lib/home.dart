import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alert Dialog with Gesture'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => _showDialog(context),
          child: Text(
            'Hello World'
          ),
        ),
      ),
    );
  } // build

  void _showDialog(BuildContext context) {
    showDialog(
      context: context, 
      barrierDismissible: false,        // 주변 화면을 눌러도 나가지지 않음
      barrierColor: Colors.amber[50], // 주변 화면 색
      builder: (context) {
        return AlertDialog(
          title: Text('Alert Title'),
          content: Text('Hello World를\nTouch 했습니다.'),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 같은 화면에서 나갈 땐, Navigator.of
                }, 
                child: Text('종료'),
              ),
            )
          ],
        );
      },
    );
  }
}