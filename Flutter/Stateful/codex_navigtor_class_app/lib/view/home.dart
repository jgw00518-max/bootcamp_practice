import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'first_page.dart';
import 'second_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Get.to(() => const FirstPage()),
              child: const Text('Go to the Screen #1'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.to(() => const SecondPage()),
              child: const Text('Go to the Screen #2'),
            ),
          ],
        ),
      ),
    );
  }
}
