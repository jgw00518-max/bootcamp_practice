// Factorial 구하기
// 4! = 4*3*2*1

// 결과
/*
  4's factorial value = 24
*/ 



main(){
  int inputValue = 4;
  int startNum = 1;
  int result = 1;

  for(int i = startNum; i <= inputValue; i++){
    result *= i;
  }
  print("$inputValue's factorial value = $result");

  
  
}