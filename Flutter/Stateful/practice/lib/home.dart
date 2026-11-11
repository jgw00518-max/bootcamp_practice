import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  // Property
  late String titleText;

  @override
  void initState() {
    super.initState();
    titleText = 'Practice';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            titleText = 'Changed';
            setState(() {});
          }, 
          child: Text('Button'),
        ),
      ),
    );
  }
}