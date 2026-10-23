class CalcBmiState {
  final double height;
  final double weight;
  final double bmi;
  final String result;
  final String resultStr;
  final String bmiImage;

  const CalcBmiState({
    this.height = 0.0,
    this.weight = 0.0,
    this.bmi = 0.0,
    this.result = "",
    this.resultStr = "",
    this.bmiImage = 'images/bmi.png',
    
  });

  CalcBmiState copyWith({
    double? height,
    double? weight,
    double? bmi,
    String? result,
    String? resultStr,
    String? bmiImage,
  }){
    return CalcBmiState(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      result: result ?? this.result,
      resultStr: resultStr ?? this.resultStr,
      bmiImage: bmiImage ?? this.bmiImage
    );
  }
}