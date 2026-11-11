import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late int count; // 클릭 누적 숫자

  @override
  void initState() {
    super.initState();
    count = 0;
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Count up"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "현재 클릭 수는 $count 입니다."
            ),
            FloatingActionButton(
              onPressed: increaseOne,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
              ),
              ElevatedButton(
                onPressed: increaseOne,
                child: Text("1씩 증가"),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: increaseOne,
        backgroundColor: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            Text('증가'),
          ],
        ),
      ),
    );
  } // build

  void increaseOne() {
    count += 2;
    setState(() {});
  }

} // class