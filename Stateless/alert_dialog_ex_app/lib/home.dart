import 'package:alert_dialog_ex_app/secondpage.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alert and push'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => _showDialog(context),
          child: Text(
            'Move the 2nd page'
          ),
        ),
      ),
    );
  } // build

  void _showDialog(BuildContext context) {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Page 이동'),
          content: Text('아래의 버튼을 누르면 \n페이지 이동을 합니다.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Secondpage();
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)
                )
              ),
              child: Text('Page 이동'),
            )
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3)
          ),
        );
      },
    );
  }
}