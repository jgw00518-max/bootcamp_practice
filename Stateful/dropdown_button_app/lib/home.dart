import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late List<String> items;    // 과일 list
  late String dropDownValue;  // Dropdown 버튼의 value
  late String imageName;      // 이미지 이름

  @override
  void initState() {
    super.initState();
    items = [
      "Apple",
      "Banana",
      "Grape",
      "Orange",
      "Pineapple",
      "Watermelon",
    ];
    dropDownValue = "Apple";
    imageName = "Apple";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drop Down Button"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: dropDownValue,
              icon: Icon(Icons.keyboard_arrow_down),
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item
                  ),
                );
              },).toList(),
              onChanged: (value) {
                dropDownValue = value.toString();
                imageName = value.toString();
                setState(() {});
              },
            ),
            Image.asset(
              "images/$imageName.png",
              width: 200,
            )
          ],
        ),
      ),
    );
  }
}