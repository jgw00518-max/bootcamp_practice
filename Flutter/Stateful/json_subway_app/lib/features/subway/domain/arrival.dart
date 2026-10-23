import 'train_position.dart';

/// API 한 건을 화면에 필요한 도착 정보로 변환한 모델입니다.
class Arrival {
  const Arrival({
    required this.trainType,
    required this.line,
    required this.direction,
    required this.arrivalMessage,
    required this.remainingSeconds,
    required this.subwayId,
    required this.trainNo,
    required this.stationId,
    this.position,
  });

  /// 상행·하행 또는 내선·외선 등 열차 운행 구분입니다.
  final String trainType;
  final String line;
  final String direction;
  final String arrivalMessage;
  final int remainingSeconds;
  final String subwayId;
  final String trainNo;
  final String stationId;
  final TrainPosition? position;

  factory Arrival.fromJson(Map<String, dynamic> json) => Arrival(
    trainType: json['updnLine'] as String? ?? '정보 없음',
    line: json['trainLineNm'] as String? ?? '노선 정보 없음',
    direction: json['arvlMsg3'] as String? ?? '',
    arrivalMessage: json['arvlMsg2'] as String? ?? '도착 정보 없음',
    remainingSeconds: int.tryParse('${json['barvlDt'] ?? 0}') ?? 0,
    subwayId: json['subwayId'] as String? ?? '',
    trainNo: json['btrainNo'] as String? ?? '',
    stationId: json['statnId'] as String? ?? '',
  );

  /// 위치 API 결과를 결합한 새 도착정보를 반환합니다.
  Arrival copyWithPosition(TrainPosition? value) => Arrival(
    trainType: trainType,
    line: line,
    direction: direction,
    arrivalMessage: arrivalMessage,
    remainingSeconds: remainingSeconds,
    subwayId: subwayId,
    trainNo: trainNo,
    stationId: stationId,
    position: value,
  );

  /// 1분 이하 또는 이미 도착한 열차는 화면에서 우선 강조합니다.
  bool get isImminent => remainingSeconds <= 60;

  /// 도착 안내 문구에서 목적역까지 남은 역 수를 읽어 냅니다.
  String? get remainingStationsLabel {
    final match = RegExp(r'\[?(\d+)\]?\s*번째 전역').firstMatch(arrivalMessage);
    if (match != null) {
      return '${match.group(1)}전역 전';
    }
    if (arrivalMessage.contains('전역')) {
      return '전역';
    }
    if (arrivalMessage.contains(' 진입')) {
      return '이번 역';
    }
    return null;
  }

  /// 초 단위 API 값을 스크린샷과 같은 분·초 도착 시간으로 표시합니다.
  String get remainingTime {
    if (remainingSeconds <= 0) return '곧 도착';
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    if (minutes == 0) return '$seconds초 후';
    return seconds == 0 ? '$minutes분 후' : '$minutes분 $seconds초 후';
  }
}
