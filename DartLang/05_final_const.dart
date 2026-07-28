main(){
  // final과 const
  String name1 = "유비";
  name1 = "장비";
  print(name1);

  final String name2 = "관우";
  // name2 = "조조"; // final이므로 변경 불가

  const String name3 = "조자룡";
  // name3 = "조조"; // const이므로 변경 불가

  // final은 실행시에 결정되는 값으로 설정한다.
  // const는 결정을 하고 실행을 한다.
  print(name2);
  print(name3);
  
  final DateTime now1 = DateTime.now();
  print(now1);
}