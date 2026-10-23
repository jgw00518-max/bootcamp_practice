/// 서울 열린데이터광장 지하철 API의 공통 설정입니다.
abstract final class SubwayApiConfig {
  static const apiKey = '78585453796a67773932754a46497a';
  static const baseUrl = 'http://swopenapi.seoul.go.kr/api/subway';
  static const timetableBaseUrl = 'http://openapi.seoul.go.kr:8088';
  static const responseFormat = 'json';
  static const serviceName = 'realtimeStationArrival';
  static const startIndex = 0;
  static const endIndex = 20;

  /// 위치 API 요청에 필요한 지하철 ID와 노선명 매핑입니다.
  static const lineNameById = <String, String>{
    '1001': '1호선',
    '1002': '2호선',
    '1003': '3호선',
    '1004': '4호선',
    '1005': '5호선',
    '1006': '6호선',
    '1007': '7호선',
    '1008': '8호선',
    '1009': '9호선',
    '1063': '경의중앙선',
    '1065': '공항철도',
    '1067': '경춘선',
    '1075': '수인분당선',
    '1077': '신분당선',
    '1092': '우이신설선',
    '1032': 'GTX-A',
  };
}
