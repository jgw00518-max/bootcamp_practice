import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Screen"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/1st"), // 미리 정해둔 경로를 지정하여 해당 화면으로
              child: Text("Go to the screen #1"),                    // 넘어가는 명령어 pushNamed
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/2nd"),
              child: Text("Go to the screen #2"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/3rd"),
              child: Text("Go to the screen #3"),
            ),
          ],
        ),
      ),
    );
  }
}