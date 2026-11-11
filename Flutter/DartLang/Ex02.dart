  // List를 이용해서 5보다 작은 숫자만 새로운 List에 생성하기
  // 입력숫자 : 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89

  // 결과
  /*
    [1, 1, 2, 3]
  */

  main(){
    List<int> numList = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89];
    List<int> numList2 = [];

    for(int i in numList){
      if(i < 5){
        numList2.add(i);
      }
    }
    print(numList2);
    
    print([for(int i in numList) if(i<5) i]); // One Line Coding
  }