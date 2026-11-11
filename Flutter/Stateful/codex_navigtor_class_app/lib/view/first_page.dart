import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 1st'),
        leading: IconButton(
          key: const Key('first_page_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: const Center(child: Text('Screen 1st')),
    );
  }
}
