main(){
  // Function의 필요 이유
  List<int> list1 = [1, 3, 5, 7, 9];
  int sum = 0;

  for(int i in list1){
    sum += i;
  }
  print("합계 : $sum");

  List<int> list2 = [10, 30, 50, 70, 90];
  int sum2 = 0;

  for(int i in list2){
    sum2 += i;
  }
  print("합계 : $sum2");

  // Function으로 관리하기
  void addList(){
    List<int> list1 = [1, 3, 5, 7, 9];
    int sum = 0;

    for(int i in list1){
      sum += i;
    }
    print("합계 : $sum");
  }

  addList();

  List<int> list11 = [1, 3, 7, 9];
  List<int> list21 = [10, 30, 50];
  List<int> list31 = List.generate(100, ((index) => index + 2));

  void addList2(List listTemp){
    int sum = 0;

    for(int i in listTemp){
      sum += i;
    }
    print("합계 : $sum");
  }

  addList2(list11);
  addList2(list21);
  addList2(list31);
  
  print("----------------------");

  int addList3(List listTemp){
    int sum = 0;

    for(int i in listTemp){
      sum += i;
    }
    return sum;
  }

  // int result = addList3(list11);
  // print("합계 : $result");

  print("합계 : ${addList3(list11)}");
  print("합계 : ${addList3(list21)}");
  print("합계 : ${addList3(list31)}");
  // addList3(list21);
  // addList3(list31);

} // End