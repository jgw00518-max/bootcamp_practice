import 'package:flutter/material.dart';

class Mail extends StatelessWidget {
  const Mail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigator_AppBar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => gosend(context),
            icon: Icon(Icons.email),
          ),
          IconButton(
            onPressed: () => goreceived(context), 
            icon: Icon(Icons.email_outlined),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('images/pikachu-1.jpg'),
              ),
              accountName: Text('Pikachu'), 
              accountEmail: Text('pikachu@naver.com'),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )
              ),
              onDetailsPressed: () {
                
              },
            ),
            ListTile(
              leading: TextButton.icon(
                onPressed: () => gosend(context),
                icon: Icon(
                  Icons.email,
                  color: Colors.blue,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                label: Text('   보낸 편지함'),
              ),
            ),
            ListTile(
              leading: TextButton.icon(
                onPressed: () => goreceived(context),
                icon: Icon(
                  Icons.email_outlined,
                  color: Colors.red,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                label: Text('   받은 편지함'),
              ),
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => gosend(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                )
              ), 
              child: Text('보낸 편지함'),
            ),
            ElevatedButton(
              onPressed: () => goreceived(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                )
              ), 
              child: Text('받은 편지함'),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Functions -----
  // pushname의 위치를 받아 navigator를 사용하는 함수 // 이런식으로 함수를 만든 후 comment를 꼭 달기

  // void navigateTo(BuildContext context, String routeName) { // 함수 한 개로 줄이는 방식
  //   Navigator.pushNamed(context, routeName);
  // }

  void gosend(BuildContext context) {                          // 함수 두 개를 이용하여 줄이는 방식
    Navigator.pushNamed(context, '/send');
  }

  void goreceived(BuildContext context) {
    Navigator.pushNamed(context, '/received');
  }
}
