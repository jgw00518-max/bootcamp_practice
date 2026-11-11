import 'package:flutter/material.dart';

class ImageApp2 extends StatelessWidget {
  const ImageApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Image Padding'),
        centerTitle: false,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0  , 80, 0, 80),
              child: Image.asset(
                'images/pikachu-2.jpg',
                width: 150,
              ),
            ),
            Image.asset(
              'images/pikachu-3.jpg',
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}