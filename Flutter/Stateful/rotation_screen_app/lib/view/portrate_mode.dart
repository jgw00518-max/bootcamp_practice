import 'package:flutter/material.dart';

class PortrateMode extends StatefulWidget {
  const PortrateMode({super.key});

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
          Text("Portrate Mode")
        ],
      ),
    );
  }
}