import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getstorage_app/second_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late TextEditingController userIdController;
  late TextEditingController passwordController;
  final box = GetStorage(); // <<<<< GetStorage 생성

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController();
    passwordController = TextEditingController();
    // 초기화
    initStorage();
  }

  void initStorage(){
    box.write("p_userId", "");
    box.write("p_password", "");
  }

  @override
  void dispose() {
    disposeStorage();
    super.dispose();
  }

  void disposeStorage(){
    box.erase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log In"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: "사용자 ID를 입력 하세요"
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "패스워드를 입력 하세요"
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if(userIdController.text.trim().isEmpty || passwordController.text.trim().isEmpty){
                    errorSnackBar();
                  }else{
                    _showDialog();
                  }
                }, 
                child: Text("Log In"),),
            ],
          ),
        ),
      ),
    );
  } // build

  // --- Functions ---
  void errorSnackBar(){
    Get.snackbar(
      "경고", 
      "다시 입력하세요",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showDialog(){
    Get.defaultDialog(
      title: "환영 합니다.",
      middleText: "확인 되었습니다",
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            saveStorage();
            Get.back();
            Get.to(SecondPage());
          }, 
          child: Text("Exit"),
        ),
      ]
    );
  }

  void saveStorage(){
    box.write("p_userId", userIdController.text.trim());
    box.write("p_password", passwordController.text.trim());
  }

} // class