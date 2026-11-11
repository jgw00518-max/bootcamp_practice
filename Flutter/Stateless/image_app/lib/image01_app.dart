import 'package:flutter/material.dart';

class Image01App extends StatelessWidget {
  const Image01App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[200],
      appBar: AppBar(
        title: Text('Image01'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(
                'images/pikachu-1.jpg'
              ),
              radius: 70,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(
                  'images/pikachu-2.jpg'
                ),
                radius: 70,
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage(
                'images/pikachu-2.jpg'
              ),
              radius: 70,
            ),
          ],
        ),
      ),
    );
  }
}