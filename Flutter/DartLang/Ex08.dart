// 구구단 출력

main(){
  
  Gugudan gugudan = Gugudan(4);
  gugudan.gugudanPrint();
  
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
    print("$num1 X ${i % 2 == 0 ? i : '*'} = ${num1 * i}");
    }
  }
}