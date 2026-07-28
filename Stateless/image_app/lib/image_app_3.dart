import 'package:flutter/material.dart';

class ImageApp3 extends StatelessWidget {
  const ImageApp3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Image Test'),
        centerTitle: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  'images/pikachu-1.jpg',
                  width: 150,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/pikachu-1.jpg',
                  width: 150,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'images/pikachu-1.jpg',
                  width: 150,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}