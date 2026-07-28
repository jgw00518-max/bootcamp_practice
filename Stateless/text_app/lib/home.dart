import 'package:flutter/material.dart'; // stl -> (tab)

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('삼국지'),
        centerTitle: true, // Center로 보이게 하기
        backgroundColor: Colors.limeAccent,
        foregroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("유비"),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text("관우"),
              ),
              Text("장비"),
            ],
          ),
        ),
      ),
    );
  }
}