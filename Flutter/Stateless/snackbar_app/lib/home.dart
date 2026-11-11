import 'package:flutter/material.dart';

// Snackbar Basic Format

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) { // context: bulid를 memory에 넣는 역할
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Snack Bar"),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Elevated Button is clicked.'),
                    backgroundColor: Colors.red,
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
      ),
    );
  }
}