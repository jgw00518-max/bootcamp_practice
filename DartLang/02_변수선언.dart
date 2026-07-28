main(){
  // 변수 선언
  // var 변수 선언: 데이터에 의한 추론형 변수 선언
  
  var name = '유비';
  name = '장비';
  print(name);

  var height = 100;
  // height = "abcd"; - 한번 타입을 정하면 다른 타입은 오류
  print(height);

  int height2 = 200;
  print(height + height2);

  var weight = 45.8;
  print(weight);

  var gender = true;
  print(gender);

  print("내 친구의 이름은 " + name + "입니다.");
  // print("내 친구의 이름은 " + height + "입니다."); -> 정수와 문자의 + 의미가 다르기때문에 오류
}