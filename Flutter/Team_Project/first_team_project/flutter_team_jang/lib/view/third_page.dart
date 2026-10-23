import 'package:flutter/material.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  // Property
  late TextEditingController num1Controller; // 첫 번째 숫자
  late TextEditingController num2Controller; // 두 번째 숫자
  late String mulResultText; // 곱셈 결과 텍스트

  @override
  void initState() {
    super.initState();
    num1Controller = TextEditingController();
    num2Controller = TextEditingController();
    mulResultText = "";
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위한 컨트롤러 해제
    num1Controller.dispose();
    num2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("곱셈"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. 첫 번째 숫자 입력받기
              TextField(
                textAlign: TextAlign.end,
                controller: num1Controller,
                decoration: const InputDecoration(
                  labelText: '첫번째 숫자를 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),

              // 2. 두 번째 숫자 입력받기
              TextField(
                textAlign: TextAlign.end,
                controller: num2Controller,
                decoration: const InputDecoration(
                  labelText: '두번째 숫자를 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // 3. OK 버튼 (곱셈 계산)
              ElevatedButton(
                onPressed: calcAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('OK'),
              ),

              const SizedBox(height: 30),

              // 4. 곱셈 결과 출력 (Text)
              Text(
                mulResultText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---- Functions ----

  // 스낵바 함수
  void _snackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("숫자를 입력하세요"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 계산 버튼 클릭 시 검증
  void calcAction() {
    if (num1Controller.text.trim().isNotEmpty &&
        num2Controller.text.trim().isNotEmpty) {
      calcResult();
    } else {
      _snackBar();
    }
  }

  // 곱셈 계산 로직
  void calcResult() {
    int num1 = int.parse(num1Controller.text.trim());
    int num2 = int.parse(num2Controller.text.trim());

    int mul = num1 * num2;

    setState(() {
      mulResultText = "$num1 * $num2 = $mul";
    });
  }
}