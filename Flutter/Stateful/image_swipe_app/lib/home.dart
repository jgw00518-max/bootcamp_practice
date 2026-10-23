import 'package:flutter/material.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

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
        title: Text("Image Swiping"),
      ),
      body: SimpleGestureDetector(
        onHorizontalSwipe: (direction) => _onHorizontalSwipe(direction),
        onVerticalSwipe: (direction) => _onVerticalSwipe(direction),
        onDoubleTap: () => _onDoubleTap(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentImage % 2 == 0 ? imageName[currentImage] : "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Image.asset(
                'images/${imageName[currentImage]}',
                width: 350,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentImage % 2 == 1 ? imageName[currentImage] : "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  } // build

  // ---- Function ----
  void _onHorizontalSwipe(SwipeDirection direction){
    if(direction == SwipeDirection.left){
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

  void _onVerticalSwipe(SwipeDirection direction){
    if(direction == SwipeDirection.up){
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

  void _onDoubleTap(){
    currentImage++;
    if(currentImage >= imageName.length){
      currentImage = 0;
    }
    setState(() {});
  }
} // class