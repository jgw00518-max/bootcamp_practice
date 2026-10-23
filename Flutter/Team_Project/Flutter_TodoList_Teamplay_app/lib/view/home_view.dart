import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class HomeView extends StatefulWidget {

  final Function(int) changeTab;

  const HomeView({
    super.key,
    required this.changeTab,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}


class _HomeViewState extends State<HomeView> {

  // Property
  late List<IconData> gridIcon;
  late List<String> gridTitle;
  late List<String> gridContent;

  final box = GetStorage();

  late String userId;

  // 오늘 전체 Todo 개수
  late int todayCount;

  // 오늘 완료한 Todo 개수
  late int doneCount;

  // 오늘 남은 Todo 개수
  late int remainingCount;

  // 오늘 할 일 달성률
  late double percent;


  @override
  void initState() {
    super.initState();

    todayCount = 0;
    doneCount = 0;
    remainingCount = 0;
    percent = 0;

    gridIcon = [
      Icons.check_circle_outline,
      Icons.add_circle_outline,
      Icons.location_on_outlined,
      Icons.camera_alt_outlined,
    ];

    gridTitle = [
      '오늘 할 일',
      '할 일 추가',
      '지도 메뉴',
      '포토 메뉴',
    ];

    // 로그인 사용자 ID
    userId = box.read('p_userId') ?? '';

    // 처음 실행할 때 Todo 개수 불러오기
    loadTodoCount();
  }


  // ---------------- Function ----------------

  // TodayView에서 저장한 최신 Todo 개수 불러오기
  void loadTodoCount() {

    todayCount = box.read('todayCount') ?? 0;

    doneCount = box.read('doneCount') ?? 0;

    // 오늘 남은 개수
    remainingCount = todayCount - doneCount;

    // 오늘 달성률
    percent = todayCount == 0
        ? 0
        : doneCount / todayCount * 100;

    // 카드에 표시할 내용
    gridContent = [
      '$remainingCount개 남음',
      '이번 달 5개',
      '최근 위치 2곳',
      '신규 등록 가능',
    ];
  }


  @override
  Widget build(BuildContext context) {

    // 홈 화면이 다시 그려질 때 최신값 불러오기
    loadTodoCount();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,

      body: Padding(
        padding: const EdgeInsets.all(32.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              height: 30,
            ),

            Text(
              '안녕하세요, $userId 님 👋',

              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),


            const Text(
              '오늘도 한 걸음 가벼운 하루를 설계해보세요.',

              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),


            const SizedBox(
              height: 30,
            ),


            Container(
              width: 350,
              height: 100,

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    const Text(
                      '오늘의 할 일 달성률',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),


                    Text(
                      '  ${percent.toStringAsFixed(0)}%',

                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(
              height: 30,
            ),


            const Text(
              '   바로가기',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(
              height: 15,
            ),


            Card(
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              color: Theme.of(context).colorScheme.tertiary,

              child: SizedBox(
                height: 450,

                child: GridView.builder(
                  padding: EdgeInsets.zero,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),

                  itemCount: gridTitle.length,

                  itemBuilder: (context, index) {

                    return GestureDetector(

                      onTap: () async{

                        if (index == 0) {

                          // 오늘 할 일 → TodayView
                          widget.changeTab(1);

                        } else if (index == 1) {
  // 할 일 추가 → AddView 이동 후 결과 대기[cite: 23]
  final result = await Get.toNamed('/add');
  
  if (result == true) {
    // 추가에 성공했다면 TodayView(1번 탭)로 이동하며 홈 화면 개수도 갱신[cite: 23]
    widget.changeTab(1);
    setState(() {});
  }
}else if (index == 2) {

                          // 지도 메뉴 → MapView
                          widget.changeTab(2);

                        } else {

                          // 포토 메뉴 → CameraView
                          widget.changeTab(3);
                        }
                      },


                      child: Card(
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        color: Colors.white,

                        child: Padding(
                          padding: const EdgeInsets.all(15),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [

                              Container(
                                padding: const EdgeInsets.all(7),

                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary,

                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),

                                child: Icon(
                                  gridIcon[index],
                                  size: 35,

                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                              ),


                              const SizedBox(
                                height: 10,
                              ),


                              Text(
                                gridTitle[index],

                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),


                              const SizedBox(
                                height: 10,
                              ),


                              Text(
                                gridContent[index],

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}