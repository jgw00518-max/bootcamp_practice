import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keyboard Enter"),
      ),
      body: Column(
        children: [
          TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              labelText: '글자를 입력하세요'
            ),
            textInputAction: TextInputAction.go,  // Enter를 누르면 onsubmitted 이벤트 시작
            onSubmitted: (value) {
              if(textEditingController.text.trim() == '' || textEditingController.text.trim().isEmpty){
                errorSnackBar();
              }else{
                showSnackBar();
              }
            },
          )
        ],
      ),
    );
  } // build

  // --- Functions ---

  void errorSnackBar(){
    Get.snackbar(
      "경고", 
      "글자를 입력하세요."
    );
  }

  void showSnackBar(){
    Get.snackbar(
      "입력 완료", 
      "입력한 글자는 ${textEditingController.text.trim()} 입니다."
    );
  }


} // class