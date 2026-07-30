import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late TextEditingController num1Controller;  // 첫 번째 숫자
  late TextEditingController num2Controller;  // 두 번째 숫자
  late TextEditingController sumresult;       // 덧셈 결과
  late TextEditingController removeresult;    // 뺄셈 결과
  late TextEditingController multiresult;     // 곱셈 결과
  late TextEditingController divisionresult;  // 나눗셈 결과

  late bool addSwitch; // 덧셈 Switch
  late bool subSwitch; // 뺄셈 Switch
  late bool mulSwitch; // 곱셈 Switch
  late bool divSwitch; // 나눗셈 Switch

  late String addSwitchReserve; // 덧셈 결과 보관용
  late String subSwitchReserve; // 뺄셈 결과 보관용
  late String mulSwitchReserve; // 곱셈 결과 보관용
  late String divSwitchReserve; // 나눗셈 결과 보관용

  @override
  void initState() {
    super.initState();
    num1Controller = TextEditingController(); // 생성자
    num2Controller = TextEditingController();
    sumresult = TextEditingController();
    removeresult = TextEditingController();
    multiresult = TextEditingController();
    divisionresult = TextEditingController();

    addSwitch = true;
    subSwitch = true;
    mulSwitch = true;
    divSwitch = true;

    addSwitchReserve = "";
    subSwitchReserve = "";
    mulSwitchReserve = "";
    divSwitchReserve = "";
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
                textAlign: TextAlign.end,             // 오른쪽 정렬 (숫자는 항상 오른쪽 정렬)
                controller: num1Controller,
                decoration: InputDecoration(
                  labelText: '첫번째 숫자를 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                textAlign: TextAlign.end,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("덧셈"),
                  Switch(
                    value: addSwitch, 
                    onChanged: (value) {
                      addSwitch = value;
                      switchCheck();
                    },
                  ),
                  Text("뺄셈"),
                  Switch(
                    value: subSwitch, 
                    onChanged: (value) {
                      subSwitch = value;
                      switchCheck();
                    },
                  ),
                  Text("곱셈"),
                  Switch(
                    value: mulSwitch, 
                    onChanged: (value) {
                      mulSwitch = value;
                      switchCheck();
                    },
                  ),
                  Text("나눗셈"),
                  Switch(
                    value: divSwitch, 
                    onChanged: (value) {
                      divSwitch = value;
                      switchCheck();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: sumresult,
                  decoration: InputDecoration(
                    labelText: '덧셈 결과',
                  ),
                  readOnly: true,
                ),
              ),
              TextField(
                textAlign: TextAlign.end,
                controller: removeresult,
                decoration: InputDecoration(
                  labelText: '뺄셈 결과',
                ),
                readOnly: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: multiresult,
                  decoration: InputDecoration(
                    labelText: '곱셈 결과',
                  ),
                  readOnly: true,
                ),
              ),
              SizedBox(                   // sizedBox : 사이 빈 공간 생성.
                height: 20, 
              ),
              TextField(
                textAlign: TextAlign.end,
                controller: divisionresult,
                decoration: InputDecoration(
                  labelText: '나눗셈 결과',
                ),
                readOnly: true,
              )
            ],
          ),
        ),
      ),
    );
  } // build

  // ---- Functions ----

  // snackBar Function
  void _snackBar(){    // 함수 하나로 합치기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("숫자를 입력하세요"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      )
    );
  }

  // 계산 function
  void calcAction (){
    if(num1Controller.text.trim().isNotEmpty && num2Controller.text.trim().isNotEmpty){
      calcResult();
    } else {
      _snackBar();
    }
  }

  void calcResult() {
    int num1 = int.parse(num1Controller.text.trim());
    int num2 = int.parse(num2Controller.text.trim());

    int sum = num1 + num2;
    int sub = num1 - num2;
    int mul = num1 * num2;

    addSwitchReserve = sum.toString();
    subSwitchReserve = sub.toString();
    mulSwitchReserve = mul.toString();

      if (num2 == 0) {
        divSwitchReserve = "Impossible";
      } else {
        double division = num1 / num2;
        divSwitchReserve = division.toString();
      }
    switchCheck();
  }

  // 지우기 function
  void clearAction(){
    num1Controller.text = ""; // num1Controller.clear(); 와 같은 방법
    num2Controller.text = "";
    sumresult.text = "";
    removeresult.clear();
    multiresult.text = "";
    divisionresult.text = "";

    addSwitchReserve = "";
    subSwitchReserve = "";
    mulSwitchReserve = "";
    divSwitchReserve = "";

    setState(() {});
  }

  void switchCheck(){
    sumresult.text = addSwitch ? addSwitchReserve : "";
    removeresult.text = subSwitch ? subSwitchReserve : "";
    multiresult.text = mulSwitch ? mulSwitchReserve : "";
    divisionresult.text = divSwitch ? divSwitchReserve : "";
    setState(() {
      
    });
  }
  

} // class