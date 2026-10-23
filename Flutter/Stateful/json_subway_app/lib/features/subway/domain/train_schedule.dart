/// 역 시간표 API의 한 열차 출발 정보입니다.
class TrainSchedule {
  const TrainSchedule({required this.departureTime, required this.destination});

  final String departureTime;
  final String destination;

  factory TrainSchedule.fromJson(Map<String, dynamic> json) => TrainSchedule(
    departureTime: json['LEFTTIME'] as String? ?? '',
    destination: json['SUBWAYENAME'] as String? ?? '행선지 정보 없음',
  );
}
