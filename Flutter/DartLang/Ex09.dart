main(){
  Gugudan gugudanEven = Gugudan(4);
  gugudanEven.gugudanPrint();
  print("-----------------------------");
  Gugudan gugudanOdd = Gugudan(7);
  gugudanOdd.gugudanPrint();
  
}

class Gugudan{
  //property
  late int num1;
  
  //constuctor
  Gugudan(int num1)
  : this.num1 = num1;

  //method
  void gugudanPrint(){

    List data = List.generate(9, (index) => index + 1);
    print("**** $num1단 ****");
    for(int i in data){
      print("${num1 % 2==0 ? '$num1 X ${i % 2 == 1 ? i : '*'} = ${num1 * i}' : '$num1 X ${i % 2 == 0 ? i : '*'} = ${num1 * i}'}"); // if 없이
      // if(num1 % 2 == 0){
      //   print("$num1 X ${i % 2 == 1 ? i : '*'} = ${num1 * i}");
      // }else{
      //   print("$num1 X ${i % 2 == 0 ? i : '*'} = ${num1 * i}");
      // }
    }
  }
}