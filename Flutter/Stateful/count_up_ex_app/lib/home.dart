import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late double count;

  @override
  void initState() {
    super.initState();
    count = 0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Count up'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: Text("현재 클릭 수는 $count 입니다."),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                  child: FloatingActionButton(
                    onPressed: increaseOne,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.add),
                  ),
                ),
                FloatingActionButton(
                  onPressed: decreaseOne,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } // build

  // ---- Functions ----
  void increaseOne() {
    count++;
    setState(() {});
  }

  void decreaseOne(){
    count--;
    setState(() {});
  }
  
} // class