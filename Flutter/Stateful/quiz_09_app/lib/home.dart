import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late List<int> danList;
  late int selectDan;
  late TextEditingController textEditingController; 

  @override
  void initState() {
    super.initState();
    int startDan = 2; // 시작 단
    int maxDan = 19;  // 끝 단
    danList = List.generate(maxDan - startDan + 1, (index) => index + startDan);

    selectDan = danList[0];

    textEditingController = TextEditingController(
      text: guguDan(selectDan)
    );
    
  }

  String guguDan(int dan){
    String result = "";
    for (int i = 1; i <= 9; i++) {
      result += "$dan X $i = ${dan * i}\n";
    }
    return result.trimRight();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$selectDan단"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: CupertinoPicker(
                itemExtent: 50, 
                onSelectedItemChanged: (value) {
                  selectDan = danList[value];
                  textEditingController.text = guguDan(selectDan);
                  setState(() {});
                }, 
                children: List.generate(
                  danList.length, 
                  (index) => Center(
                    child: Text("${danList[index]}단"),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: CupertinoTextField(
                controller: textEditingController,
                readOnly: true,
                maxLines: null,
              ),
            )
          ],
        ),
      ),
    );
  }
}