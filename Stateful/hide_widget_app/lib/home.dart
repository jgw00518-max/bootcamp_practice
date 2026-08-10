import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late bool button2Visible;
  
  @override
  void initState() {
    super.initState();
    button2Visible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hide Widget"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                button2Visible = true;
                setState(() {});
              }, 
              child: Text("1. Button"),
            ),
            Visibility(                   // 보이는 상태
              visible: button2Visible,
              child: TextButton(
                onPressed: () {
                  //
                }, 
                child: Text("2. Button"),
              ),
            ),
            TextButton(
              onPressed: () {
                button2Visible = false;
                setState(() {});
              }, 
              child: Text("3. Button"),
            ),
          ],
        ),
      ),
    );
  }
}