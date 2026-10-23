import 'package:flutter/material.dart';

class ThirdImagePage extends StatelessWidget {
  const ThirdImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Image Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/ball.jpg'),
            const Text(
              'Third Image',
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              child: const Text('Go to third page'),
              ),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              }, 
              child: const Text('Go Home'),
              )
          ],
        ),
      ),
    );
  }
}