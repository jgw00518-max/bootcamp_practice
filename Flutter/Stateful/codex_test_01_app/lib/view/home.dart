import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showKorean = true;

  static const _koreanNames = ['유비', '관우', '장비', '조조', '여포', '동탁'];
  static const _englishNames = [
    'Liu Bei',
    'Guan Yu',
    'Zhang Fei',
    'Cao Cao',
    'Lü Bu',
    'Dong Zhuo',
  ];

  @override
  Widget build(BuildContext context) {
    final names = _showKorean ? _koreanNames : _englishNames;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Text Exercise 01'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(names[0]),
            Text(names[1]),
            Text(names[2]),
            const SizedBox(height: 24),
            Text(names[3]),
            Text(names[4]),
            Text(names[5]),
            const SizedBox(height: 24),
            Switch(
              value: _showKorean,
              onChanged: (value) {
                setState(() {
                  _showKorean = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
