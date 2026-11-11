import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Buttons"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => print('text button'),
              onLongPress: () => addfunction(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red
              ),
              child: Text(
                'Text Button',
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10) 
                ),
              ), 
              child: Text(
                "Elevated Button"
              ),
            ),
            OutlinedButton(
              onPressed: () {
                
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                ),
              ), 
              child: Text(
                "Outlined Button"
              ),
            ),
            TextButton.icon(
              onPressed: () {
                
              },
              icon: Icon(
                Icons.home,
                size: 30,
                color: Colors.red,
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black
              ),
              label: Text('Go to home'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                
              },
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),                  
                ),
                minimumSize:Size(150, 40),
              ), 
              label: Text('Go to Home'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                
              },
              icon: Icon(
                Icons.home,
                color: Colors.black,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(
                  color: Colors.grey,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )
              ), 
              label: Text('Go to home'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            TextButton(
              onPressed: () => print('text button'),
              onLongPress: () => addfunction(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                minimumSize: Size(130, 40)
              ),
              child: Text(
                'TextButton',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5) 
                ),
                minimumSize: Size(90, 35)
              ), 
              child: Text(
                "ElevatedButton"
              ),
            ),
                
              ],
            )
          ],
        ),
      ),
    );
  } // build

  // ----- Function -----
  // 숫자 10과 20을 받아 덧셈하는 Function
  void addfunction(){
    int intNum1 = 10;
    int intNum2 = 20;
    
    print("$intNum1 + $intNum2 = ${intNum1 + intNum2}");
  }



} // class