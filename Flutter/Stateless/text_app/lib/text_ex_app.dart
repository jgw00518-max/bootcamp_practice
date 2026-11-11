import 'package:flutter/material.dart';

class TextExApp extends StatelessWidget {
  const TextExApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Exercise 01'),
        centerTitle: false,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("유비"),
              Text("관우"),
              Text("장비"),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("조조"),
              ),
              Text("여포"),
              Text("동탁"),
            ],
          ),
        ),
      ),
    );
  }
}