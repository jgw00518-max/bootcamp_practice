main(){
  // 조건문
  int num1 = 5;
  
  if(num1 > 10){
    print('입력된 숫자 $num1은 10보다 큰 수 입니다.');
  }else{
    print('입력된 숫자 $num1은 10보다 작거나 같은 수 입니다.');
  }

  if(num1 > 10){
    print('입력된 숫자 $num1은 10보다 큰 수 입니다.');
  }else if(num1 < 10){
    print('입력된 숫자 $num1은 10보다 작은 수 입니다.');
  }else{
    print('입력된 숫자 $num1은 10과 같은 수 입니다.');
  }

  // Exercise
  // 변수에 있는 숫자값을 비교해서
  // 숫자가 5의 배수이면 : "입력된 숫자 ___는 5의 배수 입니다."
  // 숫자가 5의 배수가 아니면 : "입력된 숫자 __는 5의 배수가 아니며 나머지 값은 ___입니다."

  int num2 = 14;
  
  if(num2 % 5 == 0){
    print("입력된 숫자 $num2는 5의 배수 입니다.");
  }else{
    print("입력된 숫자 $num2는 5의 배수가 아니며 나머지 값은 ${num2 % 5}입니다.");
  }

  // Switch
  switch(num2 % 5){
    case 0:
      print("입력된 숫자 $num2는 5의 배수 입니다.");
    default:
      print("입력된 숫자 $num2는 5의 배수가 아니며 나머지 값은 ${num2 % 5}입니다.");
  }

  // Exercise
  // num2가 2의 배수이면 '2의 배수 입니다.'
  // num2가 3의 배수이면 '3의 배수 입니다.'
  // num2가 5의 배수이면 '5의 배수 입니다.'
  // num2가 3과 5의 배수이면 '3과 5의 배수 입니다.'
  // num2가 2와 3의 배수이면 '2와 3의 배수 입니다.'
  // num2가 2와 5의 배수이면 '2와 5의 배수 입니다.'
  // 위의 3가지 조건이 아니면 '2,3,5의 배수가 아닙니다.'

  num2 = 10;

  if(num2 % 2 == 0 && num2 % 3 == 0){
    print('2와 3의 배수 입니다.');
  }else if(num2 % 2 == 0 && num2 % 5 == 0){
    print('2와 5의 배수 입니다.');
  }else if(num2 % 3 == 0 && num2 % 5 == 0){
    print('3과 5의 배수 입니다.');
  }else if(num2 % 2 == 0){
    print('2의 배수 입니다.');
  }else if(num2 % 3 == 0){
    print('3의 배수 입니다.');
  }else if(num2 % 5 == 0){
    print('5의 배수 입니다.');
  }else{
    print('2,3,5의 배수가 아닙니다.');
  } // 순서 중요

  // Exercise
  // 점수를 받아 확정으로 표시하기
  // 90점 이상 : A
  // 80점 이상 : B
  // 70점 이상 : C
  // 60점 이상 : D
  // 60점 미만 : F

  int score = 101;

  if(score > 100 || score < 0){
    print('점수를 확인하세요.');
  }else{
    String grade = ""; // 학점

    if(score >= 90){
      grade = "A";
    }else if(score >= 80){
      grade = "B";
    }else if(score >= 70){
      grade = "C";
    }else if(score >= 60){
      grade = "D";
    }else if(score < 60){
      grade = "F";
    }

  print("$grade 학점 입니다.");
  }


  // Switch문으로 위의 결과 제출하기
  
  score = 10;
  if(score > 100 || score < 0){
    print("점수를 확인하세요");
  }else{
    String grade = "";
    switch(score ~/ 10){
      case 10:  case 9: grade = "A";
      case 8:           grade = "B";
      case 7:           grade = "C";
      case 6:           grade = "D";
      default:          grade = "F";
    }

    print("$grade 학점 입니다.");
  }

  // 삼항 연산자
  bool isPublic = true;
  var result = isPublic ? "True" : "False";
  print(result);

  // 짝수 홀수 판별
  int num3 = 4;
  String numResult = num3 % 2 == 0 ? "짝수" : "홀수";
  print(numResult);

  // 다중 삼항 연산자(개인 연습)
  int num4 = 101;
  String grade4 = (num4 > 100 || num4 < 0) ? "점수를 다시 입력하세요."
  : num4 >= 90 ? "A"
  : num4 >= 80 ? "B"
  : num4 >= 70 ? "C"
  : num4 >= 60 ? "D" 
  : "F";
  print(grade4);
} // End