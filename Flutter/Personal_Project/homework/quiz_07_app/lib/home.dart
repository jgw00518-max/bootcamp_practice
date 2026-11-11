import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  String currentDateTime = "";  // 현재 시각
  DateTime? chosenDateTime;     // 선택한 날짜
  final bool _isRunning = true; // 타이머의 동작 여부
  late Color _backgroundColor;  // 배경색
  late bool _color;             // 변하는 배경색
  final int changeInterval = 1; // 배경색이 변하는 주기 설정
  late int _timerCount = 0;     // 타이머 동작 횟수를 세는 카운터


  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if(!_isRunning){
        timer.cancel();
      }
      _addItem();
    },);
    _backgroundColor = Colors.white;
    _color = false;
  }

  void _addItem(){
    final DateTime now = DateTime.now();
    currentDateTime = "${now.year}-${now.month.toString().padLeft(2, '0')}-"
                      "${now.day.toString().padLeft(2, '0')} ${_weekDayToString(now.weekday)} "
                      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:"
                      "${now.second.toString().padLeft(2, '0')}"
    ;
    if (chosenDateTime != null) {         // 선택한 시간이 null 값이 아닐시 동작
      bool isMatch = now.year == chosenDateTime!.year &&    // 선택한 시간(분 단위)과 현재 시간이 일치할 시
          now.month == chosenDateTime!.month &&
          now.day == chosenDateTime!.day &&
          now.hour == chosenDateTime!.hour &&
          now.minute == chosenDateTime!.minute;

    if (isMatch) {
      _timerCount++;
      if (_timerCount % changeInterval == 0){   // 설정한 주기가 될 때 마다 동작
        _color = !_color;                       // bool 상태 반전 (! 사용)
      }
      _backgroundColor = _color ? Colors.amber : Colors.pinkAccent; // bool 상태에 따른 배경색 변경 
    }else{
      _resetAlarmState();
    }
    }else{
      _resetAlarmState();
    }

    setState(() {});
  }

  // 선택한 시간과 달라졌을 경우 초기값으로 초기화
  void _resetAlarmState(){
    _backgroundColor = Colors.white;
    _timerCount = 0;
  }

  String _weekDayToString(int weekday){
    String dateName = "";
    switch(weekday){
      case 1:
        dateName = "월";
      case 2:
        dateName = "화";
      case 3:
        dateName = "수";
      case 4:
        dateName = "목";
      case 5:
        dateName = "금";
      case 6:
        dateName = "토";
      default:
        dateName = "일";
    }
    return dateName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,  // 배경색 설정
      appBar: AppBar(
        title: Text('Date Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "현재 시간 : $currentDateTime",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              width: 300,
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: DateTime.now(),
                use24hFormat: true,
                onDateTimeChanged: (value) {
                  chosenDateTime = value;
                  setState(() {});
                },
              ),
            ),
            Text(
              "선택시간 : ${chosenDateTime != null ? _chosenTime(chosenDateTime!) : "시간을 선택하세요"}"
            )
          ],
        ),
      ),
    );
  } // build

  // --- Functions ---
  String _chosenTime(DateTime now1){
    String chosenDateTime1 = "${now1.year}-${now1.month.toString().padLeft(2, '0')}-"
                      "${now1.day.toString().padLeft(2, '0')} ${_weekDayToString(now1.weekday)} "
                      "${now1.hour.toString().padLeft(2, '0')}:${now1.minute.toString().padLeft(2, '0')}:"
                      "${now1.second.toString().padLeft(2, '0')}"
  ;
    return chosenDateTime1;
  }



  
} // class