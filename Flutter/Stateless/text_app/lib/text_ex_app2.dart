import 'package:flutter/material.dart';

class TextExApp2 extends StatelessWidget {
  const TextExApp2({super.key});

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
              Divider(
                height: 10,
                color: Colors.blue,
                thickness: 5,
              ),
              Text("유비"),
              Text("관우"),
              Text("장비"),
              Divider(
                height: 30,
                color: Colors.red,
                thickness: 10,
              ),
              Text(
                "조조",
                style: TextStyle(
                  color: Colors.blue,        //Text의 Color
                  fontSize: 28,                //Text의 폰트 크기
                  fontWeight: FontWeight.bold, // bold체
                  letterSpacing: 10            // 자간
                ),
              ),
              Text("여포"),
              Text("동탁"),
              Divider(
                height: 10,
                color: Colors.blue,
                thickness: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('위나라'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text('촉나라'),
                  ),
                  Text('오나라'),
                ],
              ),
              Text(
                "삼국지",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}