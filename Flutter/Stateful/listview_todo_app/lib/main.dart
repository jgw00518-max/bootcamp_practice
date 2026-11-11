import 'package:flutter/material.dart';
import 'package:listview_todo_app/view/detail_list.dart';
import 'package:listview_todo_app/view/insert_list.dart';
import 'package:listview_todo_app/view/table_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        "/" :(context) => TableList(),
        "/insert" :(context) => InsertList(),
        "/detail" :(context) => DetailList()
      },
      initialRoute: "/",
    );
  }
}