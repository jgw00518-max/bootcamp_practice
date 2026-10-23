import 'package:flutter/material.dart';
import 'package:snackbar_app/mysnackbar.dart';

class Homeclass extends StatelessWidget {
  const Homeclass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Snack Bar"),
        backgroundColor: Colors.amber,
      ),
      body: MySnackBar(),
    );
  }
}