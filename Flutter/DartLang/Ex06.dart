main(){
  // 결과 : 1부터 10까지의 합은 55입니다.
  int startNum = 1; // 시작 수
  int endNum = 10; // 끝 수

  Calc calc =Calc(1, 10);
  int sum = calc.sumCalc();
  print("$startNum부터 $endNum까지의 합은 $sum입니다.");
}

class Calc{
  //property
  late int startNum;
  late int endNum;

  //constructor
  Calc(int startNum, int endNum)
  : this.startNum = startNum,
    this.endNum = endNum;

  // Calc(int startNum, int endNum){ // 같은 의미
  //   this.startNum = startNum;
  //   this.endNum = endNum;
  // }

  //method
  int sumCalc(){
    int sum = 0;
    // List.generate(endNum-startNum+1, (index) => index + startNum).map((e){
    //   sum += e;
    // }).toList();

    List data = List.generate(endNum-startNum+1, (index) => index + startNum);
    for(int i in data){
      sum += i;
    }

    // for(int i=startNum; i<=endNum; i++){
    //   sum += i;
    // }
  
    return sum;
  }
}

