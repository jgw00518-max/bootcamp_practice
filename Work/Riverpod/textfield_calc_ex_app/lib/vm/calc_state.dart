class CalcState {
  final int num1;
  final int num2;
  final int addResult;
  final int subResult;
  final int mulResult;
  final double divResult;

  const CalcState({
    this.num1 = 0,
    this.num2 = 0,
    this.addResult = 0,
    this.subResult = 0,
    this.mulResult = 0,
    this.divResult = 0.0,
  });

  CalcState copyWith({
    int? num1,
    int? num2,
    int? addResult,
    int? subResult,
    int? mulResult,
    double? divResult,
  }){
    return CalcState(
      num1: num1 ?? this.num1,
      num2: num2 ?? this.num2,
      addResult: addResult ?? this.addResult,
      subResult: subResult ?? this.subResult,
      mulResult: mulResult ?? this.mulResult,
      divResult: divResult ?? this.divResult,
    );
  }
}