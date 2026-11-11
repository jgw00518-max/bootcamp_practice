import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ★ HomeView import 삭제
// import 'package:todo_ex_app/view/home_view.dart';

// ★ TabbarView import 추가
import 'package:todo_ex_app/view/tabbar_view.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}


class _LoginViewState extends State<LoginView> {

  // Property
  late TextEditingController userIdController;
  late TextEditingController passwordController;

  final box = GetStorage();


  @override
  void initState() {
    super.initState();

    userIdController = TextEditingController();
    passwordController = TextEditingController();

    initStorage();
  }


  void initStorage() {
    box.write('p_userId', "");
    box.write('p_password', "");
  }


  @override
  void dispose() {

    // ★ controller만 정리
    userIdController.dispose();
    passwordController.dispose();

    // ★ 삭제
    // disposeStorage();

    super.dispose();
  }


  // ★ 삭제
  // void disposeStorage() {
  //   box.erase();
  // }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Theme.of(context).colorScheme.tertiary,

      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: SingleChildScrollView(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // ---------------- 상단 타이틀 ----------------

                const SizedBox(
                  height: 50,
                ),

                Container(

                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),

                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Text(
                    'HARU PLAN',

                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,

                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),


                const SizedBox(
                  height: 15,
                ),


                const Text(
                  "반가워요!\n"
                  "오늘도 한 걸음 더",

                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(
                  height: 10,
                ),


                const Text(
                  "하루플랜과 함께 정돈된 하루를 설계해보세요",

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(
                  height: 100,
                ),


                // ---------------- 아이디 ----------------

                const Text(
                  "아이디",

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),


                const SizedBox(
                  height: 8,
                ),


                TextField(
                  controller: userIdController,

                  decoration: InputDecoration(
                    hintText: "아이디를 입력하세요",

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,

                        width: 1.5,
                      ),
                    ),
                  ),
                ),


                const SizedBox(
                  height: 20,
                ),


                // ---------------- 비밀번호 ----------------

                const Text(
                  "비밀번호",

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),


                const SizedBox(
                  height: 8,
                ),


                TextField(
                  obscureText: true,

                  controller: passwordController,

                  decoration: InputDecoration(
                    hintText: "비밀번호를 입력하세요",

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,

                        width: 1.5,
                      ),
                    ),
                  ),
                ),


                const SizedBox(
                  height: 8,
                ),


                const Text(
                  '비밀번호를 잊으셨나요?',

                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(
                  height: 120,
                ),


                // ---------------- 로그인 버튼 ----------------

                SizedBox(
                  width: double.infinity,
                  height: 48,

                  child: ElevatedButton(

                    onPressed: () {
                      checkData();
                    },

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .primary,

                      foregroundColor:
                          Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),

                    child: const Text(
                      '로그인',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Text(
                        '아직 회원이 아니신가요? ',

                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),


                      Text(
                        '회원가입',

                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,

                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ---------------- Function ----------------

  void checkData() {

    if (userIdController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      errorSnackBar();

    } else {

      if (userIdController.text.trim() == 'apple' &&
          passwordController.text.trim() == '1234') {

        _showDialog();

      } else {

        checkSnackBar();
      }
    }
  }


  void _showDialog() {

    Get.defaultDialog(

      title: "반갑습니다",
      middleText: "확인되었습니다.",
      barrierDismissible: false,

      actions: [

        TextButton(

          onPressed: () {

            // ★ 로그인 정보 먼저 저장
            saveStorage();

            // ★ 다이얼로그 닫기
            Get.back();

            // ★ HomeView가 아니라 TabbarView로 이동
            Get.to(
              const TabbarView(),
            );
          },

          child: Text(
            "확인",

            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ),
      ],
    );
  }


  void saveStorage() {

    box.write(
      "p_userId",
      userIdController.text.trim(),
    );

    box.write(
      "p_password",
      passwordController.text.trim(),
    );
  }


  void errorSnackBar() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text(
          '사용자의 아이디와 비밀번호를 모두 입력하세요',
        ),

        duration: Duration(
          seconds: 2,
        ),

        backgroundColor: Colors.red,
      ),
    );
  }


  void checkSnackBar() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text(
          '사용자 ID나 암호가 올바르지 않습니다.',
        ),

        duration: Duration(
          seconds: 2,
        ),

        backgroundColor: Colors.red,
      ),
    );
  }
}