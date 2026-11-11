import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // Property
  late String userId;
  late String password;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    userId = "";
    password = "";
    loadStorage();
  }

  void loadStorage(){
    userId = box.read("p_userId");
    password = box.read("p_password");
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ID와 Password 출력"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("user ID : $userId"),
            Text("Password : $password")
          ],
        ),
      ),
    );
  }
}