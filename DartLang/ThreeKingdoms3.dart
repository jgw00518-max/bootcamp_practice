class ThreeKingdoms3 {
  // Property
  String _name;
  String _nation;

  // Constructor
  ThreeKingdoms3(String name, String nation)
    : this._name = name, 
      this._nation = nation;

  // Method
  void saySomething(){
    print("제 이름은 ${this._name}이고 조국은 ${this._nation}입니다.");
  }
}