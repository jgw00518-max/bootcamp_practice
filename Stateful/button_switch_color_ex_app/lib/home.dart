import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late bool switchValue;
  late Color buttonColor;

  @override
  void initState() {
    super.initState();
    buttonColor = Colors.blue;
    switchValue = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changed Button color on Switch'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center ,
          children: [
            ElevatedButton(
              onPressed: () => _onClick(),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
              ), 
              child: Text('Flutter'),
            ),
            Switch(
              value: switchValue, 
              onChanged: (value) {
                switchValue = value;
                _switchAction(value);
              },
            ),
          ],
        ),
      ),
    );
  } // build
    // Functions

    void _switchAction(bool value){
      if(value == true){
        buttonColor = Colors.blue;
      }else{
        buttonColor = Colors.red;
      }
      setState(() {});
    }

    void _onClick(){
      if(switchValue == true){
        buttonColor = Colors.red;
        switchValue = false;
      }else{
        buttonColor = Colors.blue;
        switchValue = true;
      }
      setState(() {
        
      });
    }
} // class 