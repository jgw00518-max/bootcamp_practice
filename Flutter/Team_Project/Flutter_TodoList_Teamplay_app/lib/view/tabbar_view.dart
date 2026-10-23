import 'package:flutter/material.dart';

import 'package:todo_ex_app/view/home_view.dart';
import 'package:todo_ex_app/view/today_view.dart';
// import 'package:todo_ex_app/view/calendar_view.dart';
import 'package:todo_ex_app/view/map_view.dart';
import 'package:todo_ex_app/view/camera_view.dart';


class TabbarView extends StatefulWidget {
  const TabbarView({super.key});

  @override
  State<TabbarView> createState() => _TabbarViewState();
}


class _TabbarViewState extends State<TabbarView> {

  // 현재 선택된 탭 번호
  late int selectedIndex;


  @override
  void initState() {
    super.initState();

    // 처음에는 홈 화면
    selectedIndex = 0;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ★ 변경
      // 기존에는 selectedIndex에 해당하는 화면 하나만 만들었지만,
      // IndexedStack은 5개의 화면을 계속 유지한다.
      body: IndexedStack(

        // ★ 현재 보여줄 화면 번호
        index: selectedIndex,

        // ★ 모든 화면을 계속 유지
        children: [
          HomeView(changeTab: changeTab),
          const TodayView(),
          // const CalendarView(),
          const MapView(),
          const CameraView(),
        ],
      ),


      bottomNavigationBar: Container(
        height: 85,
        color: Colors.white,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [

            // ---------------- 홈 ----------------

            GestureDetector(
              onTap: () {
                changeTab(0);
              },

              child: tabItem(
                Icons.home_outlined,
                '홈',
                0,
              ),
            ),


            // ---------------- 할일 ----------------

            GestureDetector(
              onTap: () {
                changeTab(1);
              },

              child: tabItem(
                Icons.check_circle_outline,
                '할일',
                1,
              ),
            ),


            // ---------------- 캘린더 ----------------

            // GestureDetector(
            //   onTap: () {
            //     changeTab(2);
            //   },

            //   child: tabItem(
            //     Icons.calendar_today_outlined,
            //     '캘린더',
            //     2,
            //   ),
            // ),


            // ---------------- 지도 ----------------

            GestureDetector(
              onTap: () {
                changeTab(2);
              },

              child: tabItem(
                Icons.location_on_outlined,
                '지도',
                2,
              ),
            ),


            // ---------------- 카메라 ----------------

            GestureDetector(
              onTap: () {
                changeTab(3);
              },

              child: tabItem(
                Icons.camera_alt_outlined,
                '카메라',
                3,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // =====================================================
  // Function
  // =====================================================

  // 선택된 탭 번호 변경
  void changeTab(int index) {

    selectedIndex = index;

    setState(() {});
  }


  // 하단 탭 하나 디자인
  Widget tabItem(
    IconData icon,
    String title,
    int index,
  ) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        Icon(
          icon,
          size: 30,

          color: selectedIndex == index
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFADB5C2),
        ),


        const SizedBox(
          height: 4,
        ),


        Text(
          title,

          style: TextStyle(
            fontSize: 12,

            color: selectedIndex == index
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFADB5C2),

            fontWeight: selectedIndex == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}