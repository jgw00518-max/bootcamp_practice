import 'package:flutter/material.dart';

class Receivedmail extends StatelessWidget {
  const Receivedmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Mail'),
        backgroundColor: Colors.red,
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