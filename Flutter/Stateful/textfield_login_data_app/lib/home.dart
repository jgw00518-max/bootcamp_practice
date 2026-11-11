import 'package:flutter/material.dart';
import 'package:textfield_login_data_app/second.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // property
  late TextEditingController userIdController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log In"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person,
                size: 200,
                color: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    labelText: '사용자 ID를 입력 하세요'
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: '패스워드를 입력 하세요'
                  ),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: checkData, 
                  child: Text('Log In'),
                ),
              ),
            ],
          ),
        ),
      )
    );
  } // build

  // --- Functions ---
  void checkData(){
    if(userIdController.text.trim().isEmpty || passwordController.text.trim().isEmpty){
      errorSnackBar();
    }else{
      if(userIdController.text.trim() == 'apple' && passwordController.text.trim() == '4321'){
        _showDialog();
      }else{
        checkSnackBar();
      }
    }
  }

  void _showDialog(){
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text("환영합니다."),
          content: Text("신분이 확인되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                String id = userIdController.text.trim();
                userIdController.text = "";
                passwordController.text = "";
                Navigator.of(context).pop();

                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) {
                      return Second(id: id);
                    },
                  )
                );
              }, 
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void errorSnackBar(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("사용자 ID와 패스워드를 입력하세요."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      )
    );
  }

  void checkSnackBar(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("사용자 ID와 패스워드가 일치 하지 않습니다."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      )
    );
  }



} // class