import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isBlackBackground = true;

  void _snackbar() {
    Get.snackbar(
      'Snack Bar',
      'ElevatedButton is clicked',
      backgroundColor: _isBlackBackground ? Colors.black : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    setState(() {
      _isBlackBackground = !_isBlackBackground;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text('Snack Bar', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _snackbar,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Snackbar Button'),
        ),
      ),
    );
  }
}
