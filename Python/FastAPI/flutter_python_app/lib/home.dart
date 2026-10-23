import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key, this.client});

  /// 테스트에서는 가짜 서버 응답을 주입할 수 있다.
  final http.Client? client;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Connect 버튼으로 받은 서버의 message 값을 표시한다.
  late String result;

  /// 서버에 보낼 숫자를 입력받는다.
  final TextEditingController inputController = TextEditingController();

  /// 서버 응답 또는 계산 결과를 읽기 전용으로 보여 준다.
  final TextEditingController resultController = TextEditingController(
    text: '_______',
  );

  late final http.Client _client;
  late final bool _ownsClient;

  @override
  void initState() {
    super.initState();
    result = '_______';
    _ownsClient = widget.client == null;
    _client = widget.client ?? http.Client();
  }

  @override
  void dispose() {
    inputController.dispose();
    resultController.dispose();
    if (_ownsClient) {
      _client.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter with FastAPI")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(result),
            ElevatedButton(
              onPressed: getJSONData,
              child: const Text('Connect'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: TextField(
                controller: inputController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '숫자 입력',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: calculate, child: const Text('X 10')),
            const SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: TextField(
                controller: resultController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '결과',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  Future<void> getJSONData() async {
    var url = Uri.parse('http://192.168.20.52:8000');
    var response = await _client.get(url); // python 파일에 있는 get과 동일
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    setState(() {
      result = dataConvertedJSON['message'];
    });
  }

  /// 입력 숫자를 FastAPI에 보내고 서버가 계산한 result를 결과칸에 표시한다.
  Future<void> calculate() async {
    final number = int.tryParse(inputController.text.trim());

    if (number == null) {
      setState(() {
        resultController.text = '숫자를 입력하세요.';
      });
      return;
    }

    final url = Uri.parse('http://192.168.20.52:8000/mul/$number');

    try {
      final response = await _client.get(url);
      final dataConvertedJson = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        resultController.text = response.statusCode == 200
            ? dataConvertedJson['result'].toString()
            : '서버 오류: ${response.statusCode}';
      });
    } catch (_) {
      setState(() {
        resultController.text = '서버 연결에 실패했습니다.';
      });
    }
  }
} // class
