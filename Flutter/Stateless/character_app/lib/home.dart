import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: Text('영웅 card'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                    'images/Lee.jpg'
                  ),
                  radius: 50,
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '성웅',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '이순신 장군',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '전적',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '62전 62승',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '옥포해전'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '사천포해전'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '당포해전'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '한산도대첩'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '부산포해전'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '명량해전'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    '노량해전'
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                    'images/turtle.gif'
                  ),
                  backgroundColor: Colors.orange,
                  radius: 50,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}