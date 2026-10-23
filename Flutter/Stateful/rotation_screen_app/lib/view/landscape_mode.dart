import 'package:flutter/material.dart';

class LandscapeMode extends StatefulWidget {
  const LandscapeMode({super.key});

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
          Text("Landscape Mode")
        ],
      ),
    );
  }
}