import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late List<String> imageName;
  late int currentImage;

  @override
  void initState() {
    super.initState();
    imageName = [
      'flower_01.png',
      'flower_02.png',
      'flower_03.png',
      'flower_04.png',
      'flower_05.png',
      'flower_06.png',
    ];
    currentImage = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("무한 이미지 반복"),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor:  Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              imageName[currentImage],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Image.asset(
              'images/${imageName[currentImage]}',
              width: 350,
            ),
            SizedBox(
              height: 10,
            ),            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pushButton(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ), 
                  child: Text('<<이전'),
                ),
                SizedBox(
                  width: 30,
                ),
                ElevatedButton(
                  onPressed: () => _pushButton(true),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ), 
                  child: Text('다음>>'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } // bulid

  // ---- Function ----

// void _prevImage() {
//     setState(() {
//       currentImage = (currentImage - 1 + imageName.length) % imageName.length;
//     });
//   }

//   // 다음 이미지로 이동 (마지막 이미지에서 누르면 첫번째로)
//   void _nextImage() {
//     setState(() {
//       currentImage = (currentImage + 1) % imageName.length;
//     });
//   }

  void _pushButton(bool isNext){
    if(isNext){
      currentImage++;
      if(currentImage >= imageName.length){
        currentImage = 0;
      }
    }else{
      currentImage--;
      if(currentImage < 0){
        currentImage = imageName.length - 1;
      } 
    }
    setState(() {});
  }
} // class