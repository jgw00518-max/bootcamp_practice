import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const _battles = [
    '옥포해전',
    '사천포해전',
    '당포해전',
    '한산도대첩',
    '부산포해전',
    '명량해전',
    '노량해전',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: const Text('영웅 Card', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.orange,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.orange,
                    backgroundImage: AssetImage('images/Lee.jpg'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black),
              const SizedBox(height: 12),
              const Text('성웅', style: TextStyle(color: Colors.white)),
              const Text(
                '이순신 장군',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              const SizedBox(height: 12),
              const Text('전적', style: TextStyle(color: Colors.white)),
              const Text(
                '62전 62승',
                style: TextStyle(color: Colors.red, fontSize: 30),
              ),
              const SizedBox(height: 16),
              ..._battles.map(
                (battle) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(battle, style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.orange,
                    backgroundImage: AssetImage('images/turtle.gif'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
