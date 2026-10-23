import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/subway_api_config.dart';
import '../domain/arrival.dart';
import '../domain/train_schedule.dart';
import '../domain/train_position.dart';

/// 서울 열린데이터광장 실시간 도착정보 API를 호출합니다.
class SubwayApi {
  SubwayApi(this._client, {this.apiKey = SubwayApiConfig.apiKey});

  final http.Client _client;
  final String apiKey;

  /// 입력한 역의 도착 예정 열차 목록을 반환합니다.
  Future<List<Arrival>> search(String stationName) async {
    final uri = Uri.parse(
      '${SubwayApiConfig.baseUrl}/$apiKey/${SubwayApiConfig.responseFormat}/${SubwayApiConfig.serviceName}/${SubwayApiConfig.startIndex}/${SubwayApiConfig.endIndex}/${Uri.encodeComponent(stationName)}',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('서버 연결에 실패했습니다. (${response.statusCode})');
    }
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final error = data['errorMessage'] as Map<String, dynamic>?;
    if (error != null && error['code'] != 'INFO-000') {
      throw Exception(error['message'] ?? '도착 정보를 찾을 수 없습니다.');
    }
    final rows = data['realtimeArrivalList'] as List<dynamic>? ?? [];
    final arrivals = rows
        .map((row) => Arrival.fromJson(row as Map<String, dynamic>))
        .toList();
    final positions = await _loadPositions(arrivals);
    return arrivals
        .map(
          (arrival) => arrival.copyWithPosition(
            positions['${arrival.subwayId}:${arrival.trainNo}'],
          ),
        )
        .toList();
  }

  /// 도착 열차가 속한 노선별 위치를 조회해 열차 번호 기준으로 결합합니다.
  Future<Map<String, TrainPosition>> _loadPositions(
    List<Arrival> arrivals,
  ) async {
    final lineIds = arrivals
        .map((arrival) => arrival.subwayId)
        .where(SubwayApiConfig.lineNameById.containsKey)
        .toSet();
    final positionGroups = await Future.wait(
      lineIds.map(_fetchPositionsForLine),
    );
    return {for (final group in positionGroups) ...group};
  }

  /// 위치 API 장애는 도착정보 화면 전체를 막지 않도록 빈 결과로 처리합니다.
  Future<Map<String, TrainPosition>> _fetchPositionsForLine(
    String subwayId,
  ) async {
    final lineName = SubwayApiConfig.lineNameById[subwayId];
    if (lineName == null) return {};
    try {
      final uri = Uri.parse(
        '${SubwayApiConfig.baseUrl}/$apiKey/${SubwayApiConfig.responseFormat}/'
        'realtimePosition/0/500/${Uri.encodeComponent(lineName)}',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) return {};
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final error = data['errorMessage'] as Map<String, dynamic>?;
      if (error != null && error['code'] != 'INFO-000') return {};
      final rows = data['realtimePositionList'] as List<dynamic>? ?? [];
      return {
        for (final row in rows)
          '${row['subwayId']}:${row['trainNo']}': TrainPosition.fromJson(
            row as Map<String, dynamic>,
          ),
      };
    } catch (_) {
      return {};
    }
  }

  /// 검색 역의 첫 노선·방향에 대한 오늘 남은 출발 시간표를 조회합니다.
  Future<List<TrainSchedule>> getTimetableFor(Arrival arrival) async {
    if (!RegExp(r'^100[1-9]$').hasMatch(arrival.subwayId) ||
        arrival.stationId.length < 4) {
      return [];
    }
    final stationCode = arrival.stationId.substring(
      arrival.stationId.length - 4,
    );
    final direction = (arrival.trainType == '상행' || arrival.trainType == '내선')
        ? '1'
        : '2';
    final weekday = switch (DateTime.now().weekday) {
      DateTime.saturday => '2',
      DateTime.sunday => '3',
      _ => '1',
    };
    try {
      final uri = Uri.parse(
        '${SubwayApiConfig.timetableBaseUrl}/$apiKey/json/'
        'SearchSTNTimeTableByIDService/1/500/$stationCode/$weekday/$direction',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) return [];
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final service =
          data['SearchSTNTimeTableByIDService'] as Map<String, dynamic>?;
      final result = service?['RESULT'] as Map<String, dynamic>?;
      if (result?['CODE'] != 'INFO-000') return [];
      final rows = service?['row'] as List<dynamic>? ?? [];
      return rows
          .map((row) => TrainSchedule.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
