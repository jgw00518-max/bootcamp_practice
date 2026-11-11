main(){
  // 구구단 함수 : 함수에서 출력 하기
  // void gugudan(int dan){
  //   for(int i=1; i<=9; i++){
  //     print("$dan X $i = ${dan * i}");
  //   } 
  // }

  // void gugudan(int dan){
  //   List data = List.generate(9, (index) => index + 1); // for 다른 방법
  //   for(int i in data){
  //     print("$dan X $i = ${dan * i}");
  //   }
  // }


  // 구구단 출력 : 구구단 결과 넘기기
  // int i = 4;

  // List gugudan2(int dan){
  //   List<int> numList =[];
  //   for(int i=1; i<=9; i++){
  //     numList.add(dan * i);
  //   }
  //   return numList;
  // }

  // List gugudan2(int dan){
  //   List data = List.generate(9, (index) => index + 1); // for 다른 방법
  //   List result = [];
  //   for(int i in data){
  //     result.add("$dan X $i = ${dan * i}")
  //   }
  //   return result;
  // }

  // List<int> gugudan3(int dan){
  //   return [for(int i=1; i<=9; i++) dan * i]; // ㄷㄷ
  // }

  // gugudan(5);
  // print(gugudan2(i));

  // 구구단 함수 : 단과 곱해지는 수 시작수와 끝 수를 입력받아 구구단 출력


  // void gugudan3(int dan, int start, int end){
  //   for(int i=start; i<=end; i++){
  //     print("$dan X $i = ${dan * i}");
  //   }
  // }
  
  // void gugudan4(int dan, int start, int end){
  //   List data = List.generate(end - start + 1, (index) => index + start);
  //   for(int i in data){
  //     print("$dan X $i = ${dan * i}");
  //   }
  // }

  // gugudan3(3, 4, 8);
  // gugudan4(5, 4, 9);

  // 구구단 함수 : 단의 결과값이 30 이상만 출력하기
  void gugudan4(int dan){
    List data = List.generate(9, (index) => index + 1);
    for(int i in data){
      if(dan * i >= 30){
        print("$dan X $i = ${dan * i}");
      }
    }
  }

  gugudan4(5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     );
}