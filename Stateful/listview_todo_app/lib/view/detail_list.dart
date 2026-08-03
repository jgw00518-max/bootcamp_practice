import 'package:flutter/material.dart';
import 'package:listview_todo_app/util/message.dart';

class DetailList extends StatefulWidget {
  const DetailList({super.key});

  @override
  State<DetailList> createState() => _DetailListState();
}

class _DetailListState extends State<DetailList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail View"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Message.imagePath,
              width: 100,
            ),
            Text(
              Message.workList
            ),
          ],
        ),
      ),
    );
  }
}