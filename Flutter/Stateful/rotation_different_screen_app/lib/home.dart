import 'package:flutter/material.dart';
import 'package:rotation_different_screen_app/view/landscape_mode.dart';
import 'package:rotation_different_screen_app/view/portrate_mode.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool _switch;

  @override
  void initState() {
    super.initState();
    _switch = false;
  }

  void toggleState(){
    _switch = !_switch;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rotation Screen"),
        centerTitle: true,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if(orientation == Orientation.portrait){
            return PortrateMode(isSwitchOn: _switch, onToggle: toggleState,);
          }else{
            return LandscapeMode(isSwitchOn: _switch, onToggle: toggleState);
          }
        },
      ),
    );
  }
}