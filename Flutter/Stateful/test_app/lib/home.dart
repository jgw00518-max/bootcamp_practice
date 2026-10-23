import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late String title;                 // 나중에 값을 넣어주기 위한 틀 - 1
  late Color appBarColor;
  late String buttonText;
  late String imageChange;
  late bool changepage;
  int clickCount = 0;

  @override                          // 초기 값 넣어주기 - 2
  void initState() {
    super.initState();
    title = "smile";
    appBarColor = Colors.amber;
    buttonText = 'Ok';
    imageChange = "smile.png";
    changepage = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center ,
          children: [
            Image.asset(
              "images/$imageChange",
              width: 100,
            ),
            ElevatedButton(        // 특정 동작 시 값을 바꾼다 - 3
              onPressed: () {
                _changepage();
              }, 
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Function -----

  void _changepage() {
    if(changepage) {
      clickCount++;

      if(clickCount % 5 == 0){
        title = "pikachu";
        appBarColor =Colors.green;
        buttonText = '네 알겠습니다';
        imageChange = 'pikachu-1.jpg';
        changepage = false;
        setState(() {});
        }
      }else{
        title = "smile";
        appBarColor = Colors.amber;
        buttonText = 'Ok';
        imageChange = "smile.png";
        changepage = true;
        setState(() {});
      }
      print(clickCount);
  }
}