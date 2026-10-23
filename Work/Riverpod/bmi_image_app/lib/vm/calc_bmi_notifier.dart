import 'package:bmi_image_app/vm/calc_bmi_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalcBmiNotifier extends Notifier<CalcBmiState>{
  @override
  CalcBmiState build() => const CalcBmiState();

  void bmiCalc(double h, double w) {
    // 1. BMI를 계산한다.
    final bmi = double.parse(
      (w / ((h / 100) * (h / 100))).toStringAsFixed(1),
    );

    List<double> table = [18.4, 22.9, 24.9, 29.9];
    List<String> labels = ['저체중', '정상체중', '과체중', '비만'];
    List<String> images = [
      'underweight.png',
      'normal.png',
      'risk.png',
      'overweight.png',
    ];
    int index = 0;

    String resultStr = '고도비만';
    String bmiImage = 'images/obese.png';

    // 2. BMI에 맞는 분류와 이미지를 선택한다.
    for (double tableData in table) {
      if (bmi <= tableData) {
        resultStr = labels[index];
        bmiImage = 'images/${images[index]}';
        break;
      }
      index++;
    }

    // 3. 최종 결과를 상태에 저장하고 화면에 반영한다.
    state = state.copyWith(
      height: h,
      weight: w,
      bmi: bmi,
      result: '귀하의 bmi 지수는 $bmi이고\n$resultStr입니다.',
      resultStr: resultStr,
      bmiImage: bmiImage,
    );
  }
}

final calcProvider = NotifierProvider<CalcBmiNotifier, CalcBmiState>(CalcBmiNotifier.new);