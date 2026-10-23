import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:json_subway_app/main.dart';

void main() {
  testWidgets('새로고침 버튼과 자동 갱신으로 도착 정보를 다시 조회한다', (tester) async {
    var requestCount = 0;
    final client = MockClient((request) async {
      if (request.url.path.contains('realtimeStationArrival')) {
        requestCount++;
      }
      final seconds = requestCount == 1 ? 180 : 120;
      return http.Response(
        '''{"errorMessage":{"status":200,"code":"INFO-000","message":"OK"},"realtimeArrivalList":[{"updnLine":"내선","trainLineNm":"성수행 - 선릉방면","arvlMsg2":"도착 예정","arvlMsg3":"역삼","barvlDt":"$seconds"}]}''',
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    await tester.pumpWidget(
      MyApp(client: client, refreshInterval: const Duration(seconds: 1)),
    );

    await tester.enterText(find.byType(TextField), '역삼');
    await tester.tap(find.byTooltip('검색'));
    await tester.pumpAndSettle();
    expect(find.text('3분 후'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '시간표 보기'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byTooltip('새로고침'));
    await tester.pumpAndSettle();
    expect(find.text('2분 후'), findsOneWidget);
    expect(requestCount, 2);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(requestCount, 3);
  });

  testWidgets('열차 구분별로 나누고 도착 시간 순으로 정렬한다', (tester) async {
    final client = MockClient(
      (request) async => http.Response(
        '''{"errorMessage":{"status":200,"code":"INFO-000","message":"OK"},"realtimeArrivalList":[{"updnLine":"내선","trainLineNm":"첫 번째","arvlMsg3":"역삼","barvlDt":"300"},{"updnLine":"외선","trainLineNm":"두 번째","arvlMsg3":"역삼","barvlDt":"60"},{"updnLine":"내선","trainLineNm":"세 번째","arvlMsg3":"역삼","barvlDt":"120"}]}''',
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    await tester.pumpWidget(MyApp(client: client));

    await tester.enterText(find.byType(TextField), '역삼');
    await tester.tap(find.byTooltip('검색'));
    await tester.pumpAndSettle();

    expect(find.text('내선 열차'), findsOneWidget);
    expect(find.text('외선 열차'), findsOneWidget);
    expect(find.textContaining('열차 구분:'), findsNothing);
    final oneMinute = tester.widget<Text>(find.text('1분 후'));
    expect(oneMinute.style?.fontSize, 24);
    expect(oneMinute.style?.color, const Color(0xFFE84242));
    await tester.scrollUntilVisible(
      find.text('5분 후'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('5분 후'), findsOneWidget);
  });

  testWidgets('실시간 위치 API의 역과 운행 상태를 카드에 표시한다', (tester) async {
    final client = MockClient((request) async {
      if (request.url.path.contains('realtimePosition')) {
        return http.Response(
          '''{"errorMessage":{"status":200,"code":"INFO-000"},"realtimePositionList":[{"subwayId":"1002","trainNo":"2403","statnNm":"삼성","trainSttus":"1"}]}''',
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response(
        '''{"errorMessage":{"status":200,"code":"INFO-000"},"realtimeArrivalList":[{"subwayId":"1002","btrainNo":"2403","updnLine":"외선","trainLineNm":"성수행 - 역삼방면","arvlMsg2":"[2]번째 전역","arvlMsg3":"역삼","barvlDt":"90"}]}''',
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    await tester.pumpWidget(MyApp(client: client));

    await tester.enterText(find.byType(TextField), '강남');
    await tester.tap(find.byTooltip('검색'));
    await tester.pumpAndSettle();

    expect(find.text('현재 위치 · 삼성 · 도착 · 2전역 전'), findsOneWidget);
  });
}
