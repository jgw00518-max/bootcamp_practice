import 'package:flutter/material.dart';
import 'package:navigator_ex/first_image_page.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First Page"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Screen 1st"),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FirstImagePage();
                },)), 
                child: Text("First image page"),
              ),
            ],
        ),
      )
    );
  }
}