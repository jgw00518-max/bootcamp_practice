main(){
  // List와 mapping을 이용한 반복 처리

  // 1부터 10까지의 합계 구하기

  int sum = 0;
  
  List.generate(10, (index) => index + 1).map((e) {
    sum += e;
  }).toList();

  print("1부터 10까지의 합계는 $sum 입니다.");

  // Exercise : numList의 합계 구하기
  List<int> numList = [1, 3, 5, 7, 9];
  int sumList = 0;

  numList.map((e) {
    sumList += e;
  }).toList();

  print(sumList);

}