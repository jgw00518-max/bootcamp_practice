import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/subway_api.dart';
import '../domain/arrival.dart';
import '../domain/train_schedule.dart';

/// 역 검색, 수동 새로고침, 주기적 자동 갱신을 관리하는 화면입니다.
class SubwayHomePage extends StatefulWidget {
  const SubwayHomePage({
    super.key,
    this._client,
    this.refreshInterval = const Duration(seconds: 30),
  });

  final http.Client? _client;

  /// 검색 성공 후 같은 역을 다시 조회하는 간격입니다.
  final Duration refreshInterval;

  @override
  State<SubwayHomePage> createState() => _SubwayHomePageState();
}

class _SubwayHomePageState extends State<SubwayHomePage> {
  final _stationController = TextEditingController();
  late final http.Client _client;
  late final SubwayApi _api;
  Timer? _refreshTimer;
  List<Arrival> _arrivals = [];
  String? _searchedStation;
  DateTime? _lastUpdatedAt;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _client = widget._client ?? http.Client();
    _api = SubwayApi(_client);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _stationController.dispose();
    if (widget._client == null) _client.close();
    super.dispose();
  }

  /// 새 검색은 기존 목록을 비우고, 성공 시 자동 갱신 타이머를 시작합니다.
  Future<void> _search() async {
    final stationName = _stationController.text.trim();
    if (stationName.isEmpty) {
      setState(() => _errorMessage = '역 이름을 입력해 주세요.');
      return;
    }
    _refreshTimer?.cancel();
    await _loadArrivals(stationName, clearPreviousResults: true);
  }

  /// 마지막으로 검색한 역을 즉시 조회하는 새로고침 버튼 동작입니다.
  Future<void> _refreshNow() async {
    final stationName = _searchedStation;
    if (stationName == null || _isLoading) return;
    await _loadArrivals(stationName, clearPreviousResults: false);
  }

  /// 타이머 갱신은 기존 목록을 유지해 요청 중에도 화면이 비지 않게 합니다.
  Future<void> _autoRefresh() async {
    final stationName = _searchedStation;
    if (stationName == null || _isLoading) return;
    await _loadArrivals(stationName, clearPreviousResults: false);
  }

  /// API 결과와 마지막 갱신 시각을 상태에 반영합니다.
  Future<void> _loadArrivals(
    String stationName, {
    required bool clearPreviousResults,
  }) async {
    setState(() {
      _isLoading = true;
      _searchedStation = stationName;
      _errorMessage = null;
      if (clearPreviousResults) {
        _arrivals = [];
      }
    });
    try {
      final arrivals = await _api.search(stationName);
      if (!mounted) return;
      setState(() {
        _arrivals = arrivals;
        _lastUpdatedAt = DateTime.now();
      });
      _startAutoRefresh();
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 중복 타이머 없이 마지막 검색 역만 일정 간격으로 갱신합니다.
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      widget.refreshInterval,
      (_) => _autoRefresh(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F8FC),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2457D6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.subway_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seoul Subway',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '실시간 도착정보',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: IconButton(
                    tooltip: '새로고침',
                    onPressed: _searchedStation == null || _isLoading
                        ? null
                        : _refreshNow,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SearchField(controller: _stationController, onSearch: _search),
            const SizedBox(height: 8),
            _RefreshStatus(
              lastUpdatedAt: _lastUpdatedAt,
              refreshInterval: widget.refreshInterval,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _arrivals.isEmpty ? null : _showTimetable,
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('시간표 보기'),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    ),
  );

  Widget _buildBody() {
    if (_isLoading && _arrivals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _arrivals.isEmpty) {
      return Center(child: Text(_errorMessage!));
    }
    if (_arrivals.isEmpty) return const SizedBox.shrink();
    final groupedArrivals = _groupArrivalsByTrainType();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final group in groupedArrivals.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_subway_rounded,
                    size: 16,
                    color: Color(0xFF2457D6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.key} 열차',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  '${group.value.length}대',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          for (final arrival in group.value) ...[
            _ArrivalCard(arrival: arrival, color: Colors.white),
            const SizedBox(height: 6),
          ],
        ],
      ],
    );
  }

  /// 도착이 빠른 순으로 정렬한 뒤 열차 구분별 섹션으로 묶습니다.
  Map<String, List<Arrival>> _groupArrivalsByTrainType() {
    final sortedArrivals = List<Arrival>.of(_arrivals)
      ..sort(
        (first, second) =>
            first.remainingSeconds.compareTo(second.remainingSeconds),
      );
    final groupedArrivals = <String, List<Arrival>>{};
    for (final arrival in sortedArrivals) {
      groupedArrivals.putIfAbsent(arrival.trainType, () => []).add(arrival);
    }
    return groupedArrivals;
  }

  /// 현재 시각 이후 출발편을 최대 여섯 개까지 빠른 시간순으로 표시합니다.
  void _showTimetable() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TimetableSheet(
        arrivals: _timetableSources(),
        loadTimetable: _api.getTimetableFor,
      ),
    );
  }

  List<Arrival> _timetableSources() {
    final sources = <String, Arrival>{};
    for (final arrival in _arrivals) {
      if (RegExp(r'^100[1-9]$').hasMatch(arrival.subwayId)) {
        sources.putIfAbsent(
          '${arrival.subwayId}:${arrival.trainType}',
          () => arrival,
        );
      }
    }
    return sources.values.toList();
  }
}

/// 자동 갱신 주기와 마지막으로 받아 온 시각을 간결하게 안내합니다.
/// 시간표에서 가까운 출발 시각을 한눈에 보여 주는 요약 카드입니다.
class _TimetableSheet extends StatelessWidget {
  const _TimetableSheet({required this.arrivals, required this.loadTimetable});

  final List<Arrival> arrivals;
  final Future<List<TrainSchedule>> Function(Arrival) loadTimetable;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: arrivals.length,
    child: SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded),
                  const SizedBox(width: 8),
                  Text('시간표', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              TabBar(
                isScrollable: true,
                tabs: [
                  for (final arrival in arrivals)
                    Tab(
                      text:
                          '${arrival.subwayId.substring(2)}호선 ${arrival.trainType}',
                    ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final arrival in arrivals)
                      FutureBuilder<List<TrainSchedule>>(
                        future: loadTimetable(arrival),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final entries = snapshot.data!;
                          if (entries.isEmpty) {
                            return const Center(child: Text('시간표를 제공하지 않습니다.'));
                          }
                          return ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) => ListTile(
                              leading: Text(
                                entries[index].departureTime.substring(0, 5),
                              ),
                              title: Text('${entries[index].destination}행'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RefreshStatus extends StatelessWidget {
  const _RefreshStatus({
    required this.lastUpdatedAt,
    required this.refreshInterval,
  });

  final DateTime? lastUpdatedAt;
  final Duration refreshInterval;

  @override
  Widget build(BuildContext context) {
    if (lastUpdatedAt == null) return const SizedBox(height: 18);
    final time = lastUpdatedAt!;
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 16,
            color: Color(0xFF2457D6),
          ),
          const SizedBox(width: 6),
          Text(
            '${refreshInterval.inSeconds}초마다 자동 갱신 · 마지막 갱신 $formattedTime',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// 상단의 밑줄 형태 역명 입력창과 검색 버튼입니다.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final Future<void> Function() onSearch;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: '역 이름을 입력하세요',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: '검색',
          onPressed: onSearch,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

/// API 한 건을 열차 구분, 방면, 위치, 도착 시간 카드로 표시합니다.
class _ArrivalCard extends StatelessWidget {
  const _ArrivalCard({required this.arrival, required this.color});

  final Arrival arrival;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isImminent = arrival.isImminent;
    const arrivalColor = Color(0xFFE84242);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120E2544),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              arrival.line,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('현재 위치 · ${_currentLocationText(arrival)}'),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: isImminent ? arrivalColor : const Color(0xFF2457D6),
                ),
                const SizedBox(width: 6),
                Text(
                  '도착 예정',
                  style: TextStyle(color: isImminent ? arrivalColor : null),
                ),
                const Spacer(),
                Text(
                  arrival.remainingTime,
                  style: TextStyle(
                    fontSize: isImminent ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isImminent ? arrivalColor : const Color(0xFF2457D6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 위치 API가 있으면 현재 역과 운행 상태를, 없으면 도착정보 위치를 보여 줍니다.
  String _currentLocationText(Arrival arrival) {
    final position = arrival.position;
    final location = position != null
        ? '${position.stationName} · ${position.statusLabel}'
        : arrival.direction.isEmpty
        ? arrival.arrivalMessage
        : arrival.direction;
    final remainingStations = arrival.remainingStationsLabel;
    return remainingStations == null
        ? location
        : '$location · $remainingStations';
  }
}
