import 'package:flutter/material.dart';

class SecondImagePage extends StatelessWidget {
  const SecondImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Image Page"),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/smile.png',
              width: 200,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, 
                child: Text("Go to Home")
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Go to the screen 2nd")
            ),
          ],
        ),
      ),
    );
  }
}