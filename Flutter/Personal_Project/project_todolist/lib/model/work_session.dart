/// 집중 세션의 저장 상태입니다.
enum WorkSessionStatus { running, paused, completed }

/// Todo에 연결된 집중 시간과 실행 상태를 SQLite와 화면 사이에 전달합니다.
class WorkSession {
  const WorkSession({
    this.id,
    required this.todoId,
    required this.plannedSeconds,
    required this.elapsedSeconds,
    required this.startedAt,
    required this.status,
    this.endsAt,
    this.pausedAt,
    this.completedAt,
  });

  final int? id;
  final int todoId;
  final int plannedSeconds;
  final int elapsedSeconds;
  final DateTime startedAt;
  final WorkSessionStatus status;
  final DateTime? endsAt;
  final DateTime? pausedAt;
  final DateTime? completedAt;

  bool get isRunning => status == WorkSessionStatus.running;
  bool get isPaused => status == WorkSessionStatus.paused;
  bool get isCompleted => status == WorkSessionStatus.completed;

  /// 실행 중에는 종료 시각을 기준으로 현재까지 흐른 시간을 계산합니다.
  int elapsedAt(DateTime now) {
    if (!isRunning || endsAt == null) return elapsedSeconds;
    final remaining = endsAt!
        .difference(now)
        .inSeconds
        .clamp(0, plannedSeconds);
    return (plannedSeconds - remaining).clamp(0, plannedSeconds);
  }

  int remainingAt(DateTime now) =>
      (plannedSeconds - elapsedAt(now)).clamp(0, plannedSeconds);

  WorkSession copyWith({
    int? id,
    int? elapsedSeconds,
    WorkSessionStatus? status,
    DateTime? endsAt,
    bool clearEndsAt = false,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    DateTime? completedAt,
  }) => WorkSession(
    id: id ?? this.id,
    todoId: todoId,
    plannedSeconds: plannedSeconds,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    startedAt: startedAt,
    status: status ?? this.status,
    endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
    pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
    completedAt: completedAt ?? this.completedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'todo_id': todoId,
    'planned_seconds': plannedSeconds,
    'elapsed_seconds': elapsedSeconds,
    'started_at': startedAt.toIso8601String(),
    'status': status.name,
    'ends_at': endsAt?.toIso8601String(),
    'paused_at': pausedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };

  factory WorkSession.fromMap(Map<String, Object?> map) => WorkSession(
    id: map['id'] as int,
    todoId: map['todo_id'] as int,
    plannedSeconds: map['planned_seconds'] as int,
    elapsedSeconds: map['elapsed_seconds'] as int,
    startedAt: DateTime.parse(map['started_at'] as String),
    status: WorkSessionStatus.values.byName(map['status'] as String),
    endsAt: map['ends_at'] == null
        ? null
        : DateTime.parse(map['ends_at'] as String),
    pausedAt: map['paused_at'] == null
        ? null
        : DateTime.parse(map['paused_at'] as String),
    completedAt: map['completed_at'] == null
        ? null
        : DateTime.parse(map['completed_at'] as String),
  );
}
