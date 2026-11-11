import 'package:flutter/material.dart';

class Sendmail extends StatelessWidget {
  const Sendmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Mail'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
        child: Column(
          children: [
            Text('유비에게 보낸 메일'),
            Text('관우에게 보낸 메일'),
            Text('장비에게 보낸 메일'),
          ],
        ),
      ),
    );
  }
}