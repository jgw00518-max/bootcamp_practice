import 'package:flutter/material.dart';
import 'package:navigator_app/third_page.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
              Navigator.pop(context);
            }, 
              child: Text("Go to the first page"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ThirdPage();
                },));
              }, 
              child: Text("Go to the Third page"),
            ),
          ],
        ),
      )

      );
  }
}