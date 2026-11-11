import 'package:flutter/material.dart';

class MySnackBar extends StatelessWidget {
  const MySnackBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Elevated Button is clicked.'),
                  backgroundColor: Colors.pink,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ),
              minimumSize: Size(90, 35)
            ),
            child: Text('Snackbar Button',),
          ),
        ],
      ),
    );
  }
}