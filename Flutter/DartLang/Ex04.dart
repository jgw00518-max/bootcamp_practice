// 입력한 숫자의 한자릿 수 정수의 합 구하기
// 입력 숫자: 12345678

// 결과
/*
  Sum of 12345678 = 36
*/

main(){
  int inputValue = 12345678;
  int calcValue = inputValue;
  int remainder = 0;
  int sum = 0;

  while(calcValue != 0){
    remainder = calcValue % 10;
    sum += remainder;
    calcValue = calcValue ~/ 10;
  }

  print("Sum of $inputValue = $sum");
}