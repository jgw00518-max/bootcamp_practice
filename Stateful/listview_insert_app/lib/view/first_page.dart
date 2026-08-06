import 'package:flutter/material.dart';
import 'package:listview_insert_app/model/animal_list.dart';

class FirstPage extends StatefulWidget {
  final List<Animal> list;

  const FirstPage({super.key, required this.list});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: widget.list.length,
          itemBuilder: (context, index) {
            return Card(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0) ,
                    child: CircleAvatar(
                      backgroundImage: AssetImage(widget.list[index].imagePath),
                      radius: 35,
                    ),
                  ),
                  Text("       ${widget.list[index].animalName} / ${widget.list[index].kind}")
                ],
              ),
            );
          },
        ),
      ),
    );
  } // build

  // --- Functions ---


} // class