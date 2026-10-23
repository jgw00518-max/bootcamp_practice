import 'package:flutter/material.dart';

class Image01App2 extends StatelessWidget {
  const Image01App2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[800],
      appBar: AppBar(
        title: Text('Image01 Ex01'),
        backgroundColor: Colors.green,
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
              radius: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                    'images/pikachu-2.jpg'
                  ),
                  radius: 50,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      'images/pikachu-3.jpg'
                    ),
                    radius: 50,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}