/// 실시간 열차 위치 API가 제공하는 현재 역과 운행 상태입니다.
class TrainPosition {
  const TrainPosition({required this.stationName, required this.statusCode});

  final String stationName;
  final String statusCode;

  factory TrainPosition.fromJson(Map<String, dynamic> json) => TrainPosition(
    stationName: json['statnNm'] as String? ?? '위치 정보 없음',
    statusCode: json['trainSttus'] as String? ?? '',
  );

  /// 숫자 상태 코드를 사용자가 이해할 수 있는 운행 상태로 바꿉니다.
  String get statusLabel => switch (statusCode) {
    '0' => '진입',
    '1' => '도착',
    '2' => '출발',
    '3' => '전역 출발',
    _ => '운행 중',
  };
}
