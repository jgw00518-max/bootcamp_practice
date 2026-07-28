main(){
  // 구구단 중 5단 출력하기
  for(int i=1; i<=9; i++){
    print("5 X $i = ${5*i}");
  }
  print("---------------------");

  for(int i=2; i<=9; i++){
    print(">>>> $i단 <<<<");
    for(int j=1; j<=9; j++){
      print("$i X $j = ${i*j}");
    }
    print("---------------------");
  }

  // Exercise: 구구단 2~9단 중 짝수단과 짝수 곱해지는 수만 출력하기
  // 단, if 문 사용 금지

  for(int dan=2; dan<=9; dan+=2){
    print(">>>> $dan <<<<");
    for(int j=2; j<=9; j+=2){
      print("$dan X $j = ${dan*j}");
    }
    print("--------------------");
  }

  // Exercise: 구구단 2~9단 중 짝수단과 짝수 곱해지는 수의 결과를 List로 저장하여
  // 해당 List의 합계와 평균 구하기
  // 단, if 문 사용 금지

  List<int> listNum = [];
  int sum = 0;

  for(int dan=2; dan<=9; dan+=2){
    for(int j=2; j<=9; j+=2){
      listNum.add(dan*j);
    }
  }
  print(listNum);

  for(int i in listNum){
    sum += i;
  }
  print("합계: $sum, 평균: ${sum/listNum.length}");

} // End