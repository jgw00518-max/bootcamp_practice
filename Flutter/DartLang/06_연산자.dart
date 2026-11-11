main(){
  // 연산자
  // 자동 증감 연산자
  int num = 0;
  num = num + 1;
  num += 1;
  num++;
  print(num);
  
  num = num - 1;
  num -= 1;
  num--;
  print(num);
  
  // Null Safety
  int num1 = 10;
  // int num2 = null;
  print(num1);
  // null을 수용 가능한 변수를 선언
  int? num2 = null;
  // num2 = 10;
  num2 ??= 10; // null을 입력하면 10을 넣겠다.
  print(num2);

  // 조건 연산자
  int num3 = 10;
  int num4 = 5;

  print(num3 < num4);
  print(num3 > num4);
  print(num3 <= num4); // =< (x)
  print(num3 >= num4); // => (x)
  print(num3 == num4);
  print(num3 != num4);

  print("===========================");
  
  print(num3 is int);
  print(num3 is String);
  print(num3 is bool);
  print(num3 is! String);

  // 논리 연산자 : and(&&) , or(||)
  bool result = 12 > 10 && 1 > 0; // true && true 만 true
  print(result);

  result = 10 > 5 || 1 > 2; // false || false 만 false
  print(result);
}