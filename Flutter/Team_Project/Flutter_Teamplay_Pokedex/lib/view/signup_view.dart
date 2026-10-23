import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokedex_app/model/user.dart';
import 'package:pokedex_app/view/login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  // ---------------- Property ----------------

  late TextEditingController idController;
  late TextEditingController passwordController;
  late TextEditingController passwordCheckController;

  // ★ GetStorage 사용
  final box = GetStorage();

  // ---------------- initState ----------------

  @override
  void initState() {
    super.initState();

    idController = TextEditingController();
    passwordController = TextEditingController();
    passwordCheckController = TextEditingController();
  }

  // ---------------- dispose ----------------

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();

    super.dispose();
  }

  // ---------------- Functions ----------------


  // ★ ID / Password 중 입력하지 않은 값이 있을 때
  void showEmptySnackbar() {
    Get.snackbar(
      '  경고',
      '  ID와 비밀번호를 모두 입력하세요.',

      // ★ 포켓볼 이미지
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

      // ★ 위쪽에서 Snackbar 출력
      snackPosition: SnackPosition.TOP,

      // ★ 빨간색 Snackbar
      backgroundColor:  Color(0xFFFBC02D),

      colorText: Colors.black,

      duration: const Duration(seconds: 2),
    );
  }


  // ★ Password와 Password Check가 다를 때
  void showPasswordFailSnackbar() {
    Get.snackbar(
      '  경고',
      '  비밀번호가 일치하지 않습니다.',

      icon: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: Image.asset(
          'images/background.png',
          width: 40,
          height: 40,
        ),
      ),

      snackPosition: SnackPosition.TOP,
      backgroundColor: Color(0xFFE53935),
      colorText: Colors.white,

      duration: const Duration(seconds: 2),
    );
  }


  // ★ 이미 가입되어 있는 ID일 때
  void showDuplicateIdSnackbar() {
    Get.snackbar(
      '경고',
      '이미 사용 중인 ID입니다.',

      icon: Image.asset(
        'images/background.png',
        width: 40,
        height: 40,
      ),

      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,

      duration: const Duration(seconds: 2),
    );
  }


  // ★ 회원가입 성공 Dialog
  void showSignupSuccessDialog(String signupId) {
    Get.defaultDialog(
      title: 'Congratulations!',
      
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3B5BA7),
      ),

      content: Column(
        children: [
          // ★ 가입한 ID도 Dialog에 표시
          Text(
            '$signupId님\n회원가입이 완료되었습니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // ★ OK 버튼 대신 포켓볼 이미지 클릭
          GestureDetector(
            onTap: () {
              // ★ TextField 초기화
              idController.clear();
              passwordController.clear();
              passwordCheckController.clear();

              // ★ 회원가입 성공 Dialog 닫기
              Get.back();

              Get.off(
                const LoginView(),
                transition: Transition.leftToRight,
                duration: const Duration(seconds: 1),
              );
            },

            child: Image.asset(
              'images/background.png',
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }


  // ---------------- 회원가입 ----------------

  // ★ Register 버튼을 눌렀을 때 실행
  void registerUser() {
    // ★ 사용자가 입력한 값 가져오기
    String id = idController.text.trim();
    String password = passwordController.text.trim();
    String passwordCheck =
        passwordCheckController.text.trim();


    // ① ★ 입력하지 않은 값이 있는지 확인
    if (id.isEmpty ||
        password.isEmpty ||
        passwordCheck.isEmpty) {
      showEmptySnackbar();
      return;
    }


    // ② ★ Password와 Password Check 비교
    if (password != passwordCheck) {
      showPasswordFailSnackbar();
      return;
    }


    // ③ ★ 기존에 저장되어 있는 ID 불러오기
    String? savedId = box.read<String>('id');


    // ★ 이미 가입되어 있는 ID와 같은 경우
    if (savedId == id) {
      showDuplicateIdSnackbar();
      return;
    }


    // ④ ★ 팀장이 만든 User Model로 회원 객체 생성
    User newUser = User(
      id: id,
      password: password,
    );


    // ⑤ ★ User Model의 ID를 GetStorage에 저장
    box.write(
      'id',
      newUser.id,
    );


    // ★ User Model의 Password를 GetStorage에 저장
    box.write(
      'password',
      newUser.password,
    );


    // ⑥ ★ 회원가입 성공 Dialog
    showSignupSuccessDialog(newUser.id);
  }


  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    // ★ main.dart의 ColorScheme 가져오기
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),

        centerTitle: true,

        backgroundColor: colorScheme.primary,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(
                height: 100,
              ),
              // ★ 회원가입 화면 포켓볼 이미지
              Image.asset(
                'images/background.png',
                width: 120,
                height: 120,
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

              const SizedBox(height: 15),


              // ★ Password 확인
              TextField(
                controller: passwordCheckController,

                // ★ 비밀번호 확인도 가리기
                obscureText: true,

                decoration: const InputDecoration(
                  labelText: 'Password Check',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),


              // ★ 회원가입 버튼
              SizedBox(
                width: 160,
                height: 45,

                child: ElevatedButton(
                  // ★ 버튼 클릭 → registerUser 함수 실행
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      )
                  ),

                  child: const Text(
                    'REGISTER',
                  ),
                ),
              ),
              SizedBox(
                height: 190,
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