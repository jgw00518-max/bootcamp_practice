import 'package:flutter/material.dart';
import 'package:navigator_ex/second_image_page.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Screen 2nd"),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Screen 2nd"),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SecondImagePage();
                    },
                  ));
                },
                child: Text("Second Image Page")
              ),
            ),
          ],
        ),
      ),
    );
  }
}