import 'package:flutter/material.dart';
import 'package:listview_todo_app/util/message.dart';

class InsertList extends StatefulWidget {
  const InsertList({super.key});

  @override
  State<InsertList> createState() => _InsertListState();
}

class _InsertListState extends State<InsertList> {
  // property
  
  // 텍스트 필드의 입력값을 제어하고 읽어오기 위한 컨트롤러
  late TextEditingController textEditingController;

  // --------------------------------------------------------
  // 개별 Boolean 변수 사용
  // late bool buySwitch;
  // late bool promiseSwitch;
  // late bool studySwitch;
  // --------------------------------------------------------

  // 선택된 카테고리의 인덱스를 하나의 정수(int) 변수로 관리
  // - 0: 구매, 1: 약속, 2: 스터디 (기본값: 0 - '구매' 선택)
  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();

    // buySwitch = true;
    // promiseSwitch = false;
    // studySwitch = false;
    // Message.imagePath = "images/cart.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add View"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ========================================================
            // 인덱스(selectedCategory) 비교를 통한 스위치 제어
            // ========================================================

            // 1. 구매 카테고리 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('구매'),
                Switch(
                  // 현재 선택된 인덱스가 0이면 스위치를 On(true)으로 표시
                  value: selectedCategory == 0, 
                  onChanged: (value) {
                    selectedCategory = 0; // 선택 상태를 0번(구매)으로 변경
                    setState(() {});      // 화면 UI 갱신
                  },
                ),
                Image.asset("images/cart.png")
              ],
            ),

            // 2. 약속 카테고리 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('약속'),
                Switch(
                  // 현재 선택된 인덱스가 1이면 스위치를 On(true)으로 표시
                  value: selectedCategory == 1, 
                  onChanged: (value) {
                    selectedCategory = 1; // 선택 상태를 1번(약속)으로 변경
                    setState(() {});      // 화면 UI 갱신
                  },
                ),
                Image.asset("images/clock.png")
              ],
            ),

            // 3. 스터디 카테고리 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('스터디'),
                Switch(
                  // 현재 선택된 인덱스가 2이면 스위치를 On(true)으로 표시
                  value: selectedCategory == 2, 
                  onChanged: (value) {
                    selectedCategory = 2; // 선택 상태를 2번(스터디)으로 변경
                    setState(() {});      // 화면 UI 갱신
                  },
                ),
                Image.asset("images/pencil.png")
              ],
            ),

            // --------------------------------------------------------
            // 개별 boolean 변수를 제어하던 스위치 코드
            // --------------------------------------------------------
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text('구매'),
            //     Switch(
            //       value: buySwitch, 
            //       onChanged: (value) {
            //         buySwitch = value;
            //         promiseSwitch = false;
            //         studySwitch = false;
            //         switchNoneCheck();
            //       },
            //     ),
            //     Image.asset("images/cart.png")
            //   ],
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text('약속'),
            //     Switch(
            //       value: promiseSwitch, 
            //       onChanged: (value) {
            //         buySwitch = false;
            //         promiseSwitch = value;
            //         studySwitch = false;
            //         switchNoneCheck();
            //       },
            //     ),
            //     Image.asset("images/clock.png")
            //   ],
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text('스터디'),
            //     Switch(
            //       value: studySwitch, 
            //       onChanged: (value) {
            //         buySwitch = false;
            //         promiseSwitch = false;
            //         studySwitch = value;
            //         switchNoneCheck();
            //       },
            //     ),
            //     Image.asset("images/pencil.png")
            //   ],
            // ),
            // --------------------------------------------------------

            // 할 일 입력 창
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: '목록을 입력 하세요'
              ),
            ),

            // 저장 버튼
            ElevatedButton(
              onPressed: () {
                // 입력창이 공백이 아닐 경우에만 저장 처리
                if (textEditingController.text.trim().isNotEmpty) {
                  addList();
                }
                Navigator.pop(context); // 이전 화면으로 돌아가기
              }, 
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  } // build

  // ========================================================
  // Functions
  // ========================================================
  
  /// 선택된 카테고리 정보와 입력한 텍스트를 전역 변수(Message)에 담아 전달하는 함수
  void addList() {
    // 선택된 인덱스 번호(selectedCategory)로 리스트 요소에 바로 접근
    // * const를 사용해 컴파일 타임 상수로 만들어 메모리를 최적화함
    const List<String> imagePaths = [
      "images/cart.png",
      "images/clock.png",
      "images/pencil.png"
    ];

    // 1. 선택된 카테고리의 이미지 경로 전달
    Message.imagePath = imagePaths[selectedCategory];
    
    // 2. 작성한 할 일 텍스트 전달
    Message.workList = textEditingController.text.trim();
    
    // 3. 메인 화면에서 데이터를 새로고침하도록 플래그 전달
    Message.action = true;
  }

  // void switchNoneCheck(){
  //   if(buySwitch == false && promiseSwitch == false && studySwitch == false){
  //     buySwitch = true;
  //     Message.imagePath = 'images/cart.png';
  //   }
  //   setState(() {});
  // }
} // class