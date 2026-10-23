  // List의 최댓값과 최댓값의 위치 구하기
  // 입력 숫자 11, 12, 13, 14, 15

  // 결과
  /*
    숫자들 중 최댓값은 15이고 5번째 값 입니다.
  */

  main(){
  List<int> numList = [16, 12, 13, 14, 15];
  int maxValue = numList[0];
  int index = 0;
  
  for(int i = 0; i < numList.length; i++){
      if(numList[i] >= maxValue){
        maxValue = numList[i];
        index = i + 1;
      }
    }
    print("숫자들 중 최댓값은 $maxValue이고 $index번째 값 입니다.");

  int minValue = numList[0];
  int index1 = 0;

  for(int i = 0; i < numList.length; i++){
      if(numList[i] <= minValue){
        minValue = numList[i];
        index1 = i + 1;
      }
    }
    print("숫자들 중 최솟값은 $minValue이고 $index1번째 값 입니다.");
  }
