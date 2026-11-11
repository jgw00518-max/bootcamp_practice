import 'dart:io';

main(){
  // for
  // 1부터 10까지 출력

  // for(start; stop; step) -> 1부터; 10까지; 1씩 증가
  for(int i = 1; i <= 10; i += 2){
    print(i);
  }

  // 1부터 10까지 합계
  int sum = 0;
  int startNum = 1;
  int endNum = 10;  // 바뀔 수 있는 부분은 변수 부분

  for(int i = startNum; i <= endNum; i++){    // 로직 부분은 바뀌면 안됨 -> 변수로 입력
    sum += i; // sum = sum + i
  }
  print("$startNum부터 $endNum까지의 합계는 $sum입니다.");

  //Exercise
  // 1부터 10까지의 수중 짝수의 합과 홀수의 합을 각각 구하기(단, for문은 1개)
  // 1부터 10까지의 수중 짝수의 합은 ___이고 홀수의 합은 ___입니다.

  int evenSum = 0;
  int oddSum = 0;
  int startNum1 = 1;
  int endNum1 = 10;

  for(int i = startNum1; i <= endNum1; i++){
    if(i % 2 == 0){
      evenSum += i;
    }else{
      oddSum += i;
    }
  }
  print('$startNum1부터 $endNum1까지의 수중 짝수의 합은 $evenSum이고 홀수의 합은 $oddSum입니다.');

  // Exercise
  // 1부터 100까지 수중 2의 배수의 합계, 5의 배수의 합계, 10의 배수의 합계 구하기
  // (단, for문은 1개)
  int sum2 = 0;
  int sum5 = 0;
  int sum10 = 0;
  int startNum2 = 1;
  int endNum2 = 100;

  for(int i = startNum2; i <= endNum2; i++){
    if(i % 2 == 0){
      sum2 += i;
    }
    if(i % 5 == 0){
      sum5 += i;
    }
    if(i % 10 == 0){
      sum10 += i;
    }
  }
  print('$startNum2부터 $endNum2까지의 수 중 2의 배수의 합계는 $sum2, 5의 배수의 합계는 $sum5, 10의 배수의 합계는 $sum10입니다.');

  // Exercise
  // 1부터 100까지 수중 2의 배수의 합계, 5의 배수의 합계, 10의 배수의 합계 구하기
  // (단, for문은 1개, if, switch 금지)
  int m2sum = 0;
  int m5sum = 0;
  int m10sum = 0;
  int startNum3 = 1;
  int endNum3 = 100;

  for(int i = startNum3; i <= endNum3; i++){
    m2sum += i % 2 == 0 ? i : 0;
    m5sum += i % 5 == 0 ? i : 0;
    m10sum += i % 10 == 0 ? i : 0;
  }
  print('$startNum3부터 $endNum3까지의 수 중 2의 배수의 합계는 $m2sum, 5의 배수의 합계는 $m5sum, 10의 배수의 합계는 $m10sum입니다.');

  // List를 반복문으로 처리하기
  List<int> numList = [1,3,5,7,9];
  for(int i = 0; i < numList.length; i++){
    print(numList[i]);
  }

  // 합계 구하기
  int sumList = 0;
  for(int i = 0; i < numList.length; i++){
    sumList += numList[i];
  }
  print(sumList);

  sumList = 0;
  for(int i in numList){
    sumList += i;
  }
  print(sumList);

  // while
  int number = 1;
  while(number <= 10){
    print(number);
    number++;
  }
  
  number = 1;
  while(true){
    print(number);
    number++;
    if(number > 10){
      break;
    }
  }

  for(int i = 0; i < numList.length; i++){ // 1,3,5,7,9
    if(numList[i] == 3){
      print(numList[i]);
      break;
    }
  }

  // continue
  for(int i = 0; i < numList.length; i++){ // 1,3,5,7,9
    if(numList[i] == 3){
      continue;
    }
    print(numList[i]);
  }
  
} // End