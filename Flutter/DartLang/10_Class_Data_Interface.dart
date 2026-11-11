main(){
  // Class와 데이터를 주고 받는 방법
  // 1. Property
  // 2. Method
  // 3. Constructor

  print("Property를 이용한 방법");
  Calc1 calc1 = Calc1();
  calc1.num1 = 1;
  calc1.num2 = 2;
  print("덧셈 결과 : ${calc1.addition()}");
  print("뺄셈 결과 : ${calc1.subtraction()}");
  print("곱셈 결과 : ${calc1.multiplication()}");
  print("나눗셈 결과 : ${calc1.division()}");

  print("\nMethod를 이용한 방법");
  Calc2 calc2 = Calc2();
  print("덧셈 결과 : ${calc2.addition(1, 2)}");
  print("뺄셈 결과 : ${calc2.subtraction(1, 2)}");

  print("\nConstructor를 이용한 방법");
  Calc3 calc3 = Calc3(3, 4);
  print("덧셈 결과 : ${calc3.addition()}");
  print("뺄셈 결과 : ${calc3.subtraction()}");
  
}

class Calc3{
  // Property
  late int num1;
  late int num2;

  // Constructor
  Calc3(int num1, int num2)
  : this.num1 = num1,
    this.num2 = num2;

  // Method
  int addition(){
    return this.num1 + this.num2;
  }
  int subtraction(){
    return this.num1 - this.num2;
  }
}
class Calc2{
  // Property
  // Constructor
  // Method
  int addition(int num1, int num2){
    return num1 + num2;
  }
  int subtraction(int num1, int num2){
    return num1 - num2;
  }
}

class Calc1{
  // Property
  int num1 = 0;
  int num2 = 0;

  // Constructor

  // Method
  int addition(){
    return this.num1 + this.num2;
  }

  int subtraction(){
    return this.num1 - this.num2;
  }

  int multiplication(){
    return this.num1 * this.num2;
  }

  double division(){
    return this.num1 / this.num2;
  }
}