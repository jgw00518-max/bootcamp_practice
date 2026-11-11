import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late bool switchValue;    // Switch의 상태
  late String switchText;   // switch 옆 text의 값
  late String appbarText;   // appbar의 text의 값
  late String imageChange;  // image

  @override
  void initState() {
    super.initState();
    switchValue = true;
    switchText = 'Pikachu';
    appbarText = 'Pikachu';
    imageChange = "pikachu-1.jpg";
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appbarText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('images/$imageChange'),
              radius: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(switchText),
                Switch(
                  value: switchValue, 
                  onChanged: (value) {
                    switchValue = value;
                    _switchAction(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---

  // -----------------------------------------------------
  // Date   :
  // Desc   : 
  // Author :
  // -----------------------------------------------------
  void _switchAction(bool value){
    if(value == true){
      switchText = 'Pikachu';
      appbarText = 'Pikachu';
      imageChange ='pikachu-1.jpg';
    }else{
      switchText = 'Smile'; 
      appbarText = 'Smile';
      imageChange ='smile.png';
    }
    setState(() {});
  }
} // class