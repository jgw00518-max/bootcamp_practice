import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, // body의 background color
      appBar: AppBar(
        title: Text("Image Test"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/smile.png',
                width: 100,
              ),
              Image.asset(
                'images/smile.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain, // default fitting
              ),
              Image.asset(
                'images/smile.png',
                width: 50,
                height: 100,
                fit: BoxFit.fill,
              ),
              Image.asset(
                'images/smile.png',
                width: 50,
                height: 100,
                fit: BoxFit.fitWidth,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                    Image.asset(
                      'images/smile.png',
                      height: 100,
                    ),
                  ],
                ),
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
              Image.asset(
                'images/smile.png',
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}