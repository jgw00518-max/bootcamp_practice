import 'package:flutter/material.dart';
import 'package:navigator_ex/third_image_page.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 3rd'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Screen 3rd'),

            ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                return ThirdImagePage();  
                }));
              },
              child: const Text('Third Image Page'),
            ),
          ],
        ),
      ),
    );
  }
}