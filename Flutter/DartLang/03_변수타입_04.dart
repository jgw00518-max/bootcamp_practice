main(){
  // var와 Dynamic
  var name = "유비";
  name = "관우";
  // name = 1; // name의 추론 결과는 문자열로 선언되었으므로 숫자 데이터를 사용 할 수 없음.
  print(name);
  
  dynamic name1 = "장비";
  name1 = "조자룡";
  name1 = 10;

  int num1 = 100;
  print(name1 + num1);
}