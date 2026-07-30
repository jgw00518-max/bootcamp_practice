import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late TextEditingController heightController;  // 키 입력 값
  late TextEditingController weightController;  // 몸무게 입력 값
  late String bmiCalcResult;
  
  int arrowIndex = -1;
  
  @override
  void initState() {
    super.initState();
    heightController = TextEditingController();
    weightController = TextEditingController();
    bmiCalcResult = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI 계산기'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: heightController,
              decoration: InputDecoration(
                labelText: "신장을 입력하세요 (단위: cm)"
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: "몸무게을 입력하세요 (단위: kg)"
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                calcFunction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                )
              ), 
              child: Text("BMI 계산"),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              bmiCalcResult,
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),

            Row(
              children: [
                // 0번: 저체중 위치
                Expanded(
                  child: Center(
                    child: arrowIndex == 0
                        ? Image.asset('images/arrow.webp', height: 30)
                        : SizedBox(height: 30),
                  ),
                ),
                // 1번: 정상체중 위치
                Expanded(
                  child: Center(
                    child: arrowIndex == 1
                        ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                          child: Image.asset('images/arrow.webp', height: 30),
                        )
                        : SizedBox(height: 30),
                  ),
                ),
                // 2번: 과체중 위치
                Expanded(
                  child: Center(
                    child: arrowIndex == 2
                        ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: Image.asset('images/arrow.webp', height: 30),
                        )
                        : SizedBox(height: 30),
                  ),
                ),
                // 3번: 비만 위치
                Expanded(
                  child: Center(
                    child: arrowIndex == 3
                        ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 17, 0),
                          child: Image.asset('images/arrow.webp', height: 30),
                        )
                        : SizedBox(height: 30),
                  ),
                ),
                // 4번: 고도비만 위치
                Expanded(
                  child: Center(
                    child: arrowIndex == 4
                        ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 13, 0),
                          child: Image.asset('images/arrow.webp', height: 30),
                        )
                        : SizedBox(height: 30),
                  ),
                ),
              ],
            ),

            Image.asset(
              'images/bmi.jpg',
                fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  } // build

  // ---- Function ----


  // bmi 수치 계산
  void calcFunction(){
    if(heightController.text.trim().isEmpty || weightController.text.trim().isEmpty){
      errorSnackBar();
    }else{
      calcAction();
    }
  }

  void calcAction(){
    String resultStr;
    double height = double.parse(heightController.text.trim())/100;
    double weight = double.parse(weightController.text.trim());

    double bmi = double.parse((weight / (height * height)).toStringAsFixed(1));

    if(bmi <= 18.4){
      resultStr = "저체중";
      arrowIndex = 0;
    }else if(bmi >= 18.5 && bmi <= 22.9){
      resultStr = "정상체중";
      arrowIndex = 1;
    }else if(bmi >= 23 && bmi <= 24.9){
      resultStr = "과체중";
      arrowIndex = 2;
    }else if(bmi >= 25 && bmi <= 29.9){
      resultStr = "비만";
      arrowIndex = 3;
    }else{
      resultStr ="고도비만";
      arrowIndex = 4;
    }

    bmiCalcResult = "귀하의 bmi 지수는 $bmi 이고 $resultStr입니다.";
    setState(() {});
    }
  
  void errorSnackBar(){

  }

} // class