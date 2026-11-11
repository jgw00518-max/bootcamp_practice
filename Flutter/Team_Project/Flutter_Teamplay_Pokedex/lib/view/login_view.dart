import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/view/region_view.dart'; 
import 'package:pokedex_app/view/signup_view.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // ---------------- Property ----------------

  late TextEditingController idController;
  late TextEditingController passwordController;

  // ★ GetStorage 사용
  final box = GetStorage();

  // ---------------- initState ----------------

  @override
  void initState() {
    super.initState();

    idController = TextEditingController();
    passwordController = TextEditingController();
  }

  // ---------------- dispose ----------------

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ---------------- Functions ----------------


  // ★ ID 또는 Password를 입력하지 않았을 때
  void showEmptySnackbar() {
    Get.snackbar(
      '  경고',
      '  ID와 비밀번호를 입력하세요',

      // ★ Snackbar 왼쪽 포켓볼 이미지
      icon: Padding(
        padding: const EdgeInsets.only(
          left: 15
        ),
        child: Image.asset(
          'images/background.png',
          width: 40,
          height: 40,
        ),
      ),

      // ★ 화면 위쪽에서 Snackbar 출력
      snackPosition: SnackPosition.TOP,

      // ★ 빨간색 배경
      backgroundColor:  Color(0xFFFBC02D),

      // ★ 흰색 글씨
      colorText: Colors.black,

      duration: const Duration(seconds: 2),
    );
  }


  // ★ 입력한 ID / Password가 저장된 정보와 다를 때
  void showLoginFailSnackbar() {
    Get.snackbar(
      '  경고',
      '  ID와 비밀번호가 일치하지 않습니다.',

      // ★ Snackbar 왼쪽 포켓볼 이미지
      icon: Padding(
        padding: const EdgeInsets.only(
          left: 15
        ),
        child: Image.asset(
          'images/background.png',
          width: 40,
          height: 40,
        ),
      ),

      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }


  // ★ 로그인 성공했을 때 Dialog
  void showLoginSuccessDialog(String loginId) {
    Get.defaultDialog(
      title: '로그인 완료',
      titleStyle: const TextStyle(
      color: Color(0xFF3B5BA7),
      fontWeight: FontWeight.bold,
      fontSize: 16,
  ),

      content: Column(
        children: [
          // ★ 실제 로그인한 ID 출력
          Text(
            '환영합니다 $loginId님!',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // ★ OK 버튼 대신 포켓볼 이미지
          GestureDetector(
            onTap: () {
              // ★ 기존 로그인 입력값 삭제
              idController.clear();
              passwordController.clear();

              // ★ Dialog 닫기
              Get.back();

              // ★ RegionView로 이동
              // ★ 로그인한 ID도 함께 전달
              Get.to(
                const RegionView(),
                arguments: loginId,
                transition: Transition.circularReveal,
                duration: Duration(seconds: 1),
              );
            },

            child: Image.asset(
              'images/background.png',
              width: 45,
              height: 45,
            ),
          ),
        ],
      ),
    );
  }


  // ★ 로그인 확인
  void login() {
    // ★ TextField에서 사용자가 입력한 값 가져오기
    String loginId = idController.text.trim();
    String loginPassword = passwordController.text.trim();


    // ① ★ ID 또는 Password가 비어있는지 확인
    if (loginId.isEmpty || loginPassword.isEmpty) {
      showEmptySnackbar();
      return;
    }


    // ② ★ GetStorage에서 회원가입한 ID 불러오기
    String? savedId = box.read<String>('id');

    // ★ GetStorage에서 회원가입한 Password 불러오기
    String? savedPassword = box.read<String>('password');


    // ③ ★ 저장된 회원정보가 없을 경우
    if (savedId == null || savedPassword == null) {
      showLoginFailSnackbar();
      return;
    }


    // ④ ★ 입력한 ID / Password와 저장된 정보 비교
    if (loginId == savedId &&
        loginPassword == savedPassword) {

      // ★ 둘 다 일치 → 로그인 성공
      showLoginSuccessDialog(loginId);

    } else {

      // ★ 하나라도 다름 → 로그인 실패
      showLoginFailSnackbar();
    }
  }


  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    // ★ main.dart의 ColorScheme 가져오기
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
              ),
              // ★ 로그인 화면 포켓볼 이미지
              Image.asset(
                'images/background.png',
                width: 270,
                height: 270,
              ),

              const SizedBox(height: 30),

              // ★ ID 입력
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),


              // ★ Password 입력
              TextField(
                controller: passwordController,

                // ★ 비밀번호 가리기
                obscureText: true,

                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 45),


              // ★ LOGIN 버튼
              SizedBox(
                width: 160,
                height: 45,

                child: ElevatedButton(
                  // ★ 로그인 검사 함수 실행
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      )
                  ),

                  child: const Text('LOGIN'),
                ),
              ),

              const SizedBox(height: 10),


              // ★ 회원가입 페이지로 이동
              TextButton(
                onPressed: () async {

                  // ★ SignupView로 이동
                  await Get.to(
                    const SignupView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(
                      seconds: 1,
                    )
                  );

                  // ★ 다시 LoginView로 돌아오면
                  // 이전 입력값 삭제
                  idController.clear();
                  passwordController.clear();
                },

                child: const Text(
                  'Go to Register',
                ),
              ),
              SizedBox(
                height: 90,
              ),
              Image.asset(
                'images/logo.png',
                height: 40,
                width: 80,
              )
            ],
          ),
        ),
      ),
    );
  }
}