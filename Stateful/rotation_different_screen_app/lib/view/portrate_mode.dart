import 'package:flutter/material.dart';

class PortrateMode extends StatefulWidget {
  final bool isSwitchOn;
  final VoidCallback onToggle;  // callback 연습
  const PortrateMode({super.key, required this.isSwitchOn, required this.onToggle});

  @override
  State<PortrateMode> createState() => _PortrateModeState();
}

class _PortrateModeState extends State<PortrateMode> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSwitchOn ? Colors.red : Colors.blue,
              foregroundColor: Colors.white
            ),
            child: Text(widget.isSwitchOn ? "Flutter" : "Hello")
          ),
        ],
      ),
    );
  }
}