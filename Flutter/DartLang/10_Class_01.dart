import 'ThreeKingdoms3.dart';

main(){
  // Class
  // Instance, 객체, Object 만들기
  ThreeKingdoms threeKingdoms = ThreeKingdoms();
  ThreeKingdoms threeKingdoms1 = ThreeKingdoms();
  
  print(threeKingdoms.name);
  print(threeKingdoms1.name);

  print(threeKingdoms == threeKingdoms1);

  threeKingdoms.name = "조조";
  threeKingdoms.sayName();
  threeKingdoms1.sayName();

  // 생성자를 통한 객체 구성
  ThreeKingdoms2 threeKingdoms2 = ThreeKingdoms2("유비", "촉나라");
  threeKingdoms2.saySomething();

  // 외부파일에서 Class 불러오기
  ThreeKingdoms3 threeKingdoms3 =ThreeKingdoms3("조조", "위나라");
  threeKingdoms3.saySomething();
  

}

  // --- Class 만들기 ---
class ThreeKingdoms{
  // Property, Field, 전역변수(Global Variable)
  String name = "유비";

  // Constructor

  // Method
  void sayName(){
    print("내 이름은 ${this.name}입니다.");
  }
}

class ThreeKingdoms2 {
  // Property
  String _name;
  String _nation;

  // Constructor
  ThreeKingdoms2(String name, String nation)
    : this._name = name, 
      this._nation = nation;

  // Method
  void saySomething(){
    print("제 이름은 ${this._name}이고 조국은 ${this._nation}입니다.");
  }
}