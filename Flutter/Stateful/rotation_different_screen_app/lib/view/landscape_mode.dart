import 'package:flutter/material.dart';

class LandscapeMode extends StatefulWidget {
  final bool isSwitchOn;
  final VoidCallback onToggle;  // callback 연습
  const LandscapeMode({super.key, required this.isSwitchOn, required this.onToggle});

  @override
  State<LandscapeMode> createState() => _LandscapeModeState();
}

class _LandscapeModeState extends State<LandscapeMode> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: widget.onToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSwitchOn ? Colors.red : Colors.blue,
              foregroundColor: Colors.white
            ), 
            child: Text("Flutter"),
          ),
          Switch(
            value: widget.isSwitchOn, 
            onChanged: (value) => widget.onToggle(),
          ),
        ],
      ),
    );
  }
}