import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late TextEditingController num1Controller;
  late TextEditingController num2Controller;
  late TextEditingController sumresult;
  late TextEditingController removeresult;
  late TextEditingController multiresult;
  late TextEditingController divisionresult;

  @override
  void initState() {
    super.initState();
    num1Controller = TextEditingController(); // 생성자
    num2Controller = TextEditingController(); // 생성자
    sumresult = TextEditingController();
    removeresult = TextEditingController();
    multiresult = TextEditingController();
    divisionresult = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("간단한 계산기"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: num1Controller,
                decoration: InputDecoration(
                  labelText: '첫번째 숫자를 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: num2Controller,
                decoration: InputDecoration(
                  labelText: '두번째 숫자를 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: calcAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),
                      child: Text('계산하기'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: clearAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),                  
                      child: Text('지우기'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: TextField(
                  controller: sumresult,
                  decoration: InputDecoration(
                    labelText: '덧셈 결과',
                  ),
                ),
              ),
              TextField(
                controller: removeresult,
                decoration: InputDecoration(
                  labelText: '뺄셈 결과',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: TextField(
                  controller: multiresult,
                  decoration: InputDecoration(
                    labelText: '곱셈 결과',
                  ),
                ),
              ),
              TextField(
                controller: divisionresult,
                decoration: InputDecoration(
                  labelText: '나눗셈 결과',
                ),
              )
            ],
          ),
        ),
      ),
    );
  } // build

  // ---- Functions ----


  void _snackBar(String message, Color color){    // 함수 하나로 합치기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: color,
      )
    );
  }

  void calcAction (){
    if(num1Controller.text.trim().isNotEmpty && num2Controller.text.trim().isNotEmpty){
    int num1 = int.parse(num1Controller.text.trim());
    int num2 = int.parse(num2Controller.text.trim());
    int sum = num1 + num2;
    int remove = num1 - num2;
    int multi = num1 * num2;

    sumresult.text = sum.toString();
    removeresult.text = remove.toString();
    multiresult.text = multi.toString();

    if (num2 == 0) {
        divisionresult.text = "";
        _snackBar("0으로 나눌 수 없습니다.", Colors.red);
      } else {
        double division = num1 / num2;
        divisionresult.text = division.toString();
      }

    setState(() {});
    }else{
      _snackBar("숫자를 입력하세요", Colors.red);
    }
  }

  void clearAction(){
    num1Controller.text = "";
    num2Controller.text = "";
    sumresult.text = "";
    removeresult.text = "";
    multiresult.text = "";
    divisionresult.text = "";

    setState(() {});
  }

} // class