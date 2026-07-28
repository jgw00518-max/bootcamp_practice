main(){
  // List Collection
  List threeKingdoms = [];
  
  // List에 데이터 추가하기
  threeKingdoms.add("위");
  threeKingdoms.add("촉");
  threeKingdoms.add("오");


  // 원하는 데이터만 출력하기
  print(threeKingdoms[0]);

  // 데이터 수정: 위 -> we
  threeKingdoms[0] = "we";

  // 데이터 삭제: 촉을 삭제
  threeKingdoms.removeAt(1); // Index번호로 삭제
  threeKingdoms.remove('we'); // value로 삭제

  // List의 데이터 갯수 파악
  print(threeKingdoms.length);
  
  //threekingdoms에 숫자 추가 하기
  threeKingdoms.add(1);

  print(threeKingdoms);

  print("===============================");

  //List의 정해진 변수 타입의 데이터만 추가하기
  List<String> threeKingdoms2 = [];
  threeKingdoms2.add("we");
  // threeKingdoms2.add(100); // 문자만 등록 가능

  print(threeKingdoms2);

  print("===============================");

  // List 선언 시 초기 값 할당 후 실행
  List<String> threeKingdoms3 = ['위', '촉', '오'];

  // 위나라가 삼국을 통일 했습니다.
  print("${threeKingdoms3[0]}나라가 삼국을 통일 했습니다.");


  // 사칙연산
  // 1부터 5까지의 정수 Data를 가지고 있는 List 만들기 (단, 정수만 입력 가능하게)
  // 6부터 10까지의 정수 Data를 가지고 있는 List 만들기 (단, 정수만 입력 가능하게)

  List<int> num1 = [1,2,3,4,5];
  List<int> num2 = [6,7,8,9,10];

  // num1의 3과 num2의 9를 가지고 덧셈 뺄셈 구하기

  print("3 + 9 = ${num1[2] + num2[3]}");
  print(num1[2] - num2[3]);
}