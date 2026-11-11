import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_address_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('첫 화면은 주소 검색과 상세주소 입력란을 제공한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KakaoAddressApp());

    expect(find.text('KaKao 주소 API 연동'), findsOneWidget);
    expect(find.text('주소 검색'), findsOneWidget);
    expect(find.text('선택한 주소(기본주소)'), findsOneWidget);
    expect(find.text('나머지 주소(상세주소)'), findsOneWidget);
    expect(find.text('저장된 주소'), findsOneWidget);
  });
}
