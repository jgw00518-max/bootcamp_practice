import 'package:flutter/material.dart';

class ImageApp4 extends StatelessWidget {
  const ImageApp4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/pikachu-1.jpg',
              width: 150,
            ),
            Text('pikachu-1'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/pikachu-2.jpg',
                  width: 150,
                ),
                Text('pikachu-2.jpg')
              ],
            ),
            Image.asset(
              'images/pikachu-3.jpg',
              width: 150,
            ),
            Text('pikachu-3')
          ],
        ),
      ),
    );
  }
}