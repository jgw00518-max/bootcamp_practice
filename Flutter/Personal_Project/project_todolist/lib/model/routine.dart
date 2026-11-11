/// 반복 규칙과 Todo 생성에 사용할 루틴 템플릿을 표현합니다.
class Routine {
  const Routine({
    this.id,
    required this.title,
    this.memo = '',
    this.category = '없음',
    this.categoryId,
    this.priority = 1,
    this.estimatedMinutes = 30,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.hasTime = true,
    required this.repeatDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String memo;
  final String category;
  final int? categoryId;
  final int priority;
  final int estimatedMinutes;
  final int scheduledHour;
  final int scheduledMinute;
  final bool hasTime;
  final Set<int> repeatDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  /// 지정한 날짜가 활성 기간과 반복 요일에 포함되는지 확인합니다.
  bool appliesTo(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDate == null
        ? null
        : DateTime(endDate!.year, endDate!.month, endDate!.day);
    return isActive &&
        !day.isBefore(start) &&
        (end == null || !day.isAfter(end)) &&
        repeatDays.contains(day.weekday);
  }

  Routine copyWith({bool? isActive}) => Routine(
    id: id,
    title: title,
    memo: memo,
    category: category,
    categoryId: categoryId,
    priority: priority,
    estimatedMinutes: estimatedMinutes,
    scheduledHour: scheduledHour,
    scheduledMinute: scheduledMinute,
    hasTime: hasTime,
    repeatDays: repeatDays,
    startDate: startDate,
    endDate: endDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'memo': memo,
    'category': category,
    'category_id': categoryId,
    'priority': priority,
    'estimated_minutes': estimatedMinutes,
    'scheduled_hour': scheduledHour,
    'scheduled_minute': scheduledMinute,
    'has_time': hasTime ? 1 : 0,
    'repeat_days': (repeatDays.toList()..sort()).join(','),
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory Routine.fromMap(Map<String, Object?> map) => Routine(
    id: map['id'] as int,
    title: map['title'] as String,
    memo: map['memo'] as String? ?? '',
    category: map['category'] as String? ?? '없음',
    categoryId: map['category_id'] as int?,
    priority: map['priority'] as int? ?? 1,
    estimatedMinutes: map['estimated_minutes'] as int? ?? 30,
    scheduledHour: map['scheduled_hour'] as int,
    scheduledMinute: map['scheduled_minute'] as int,
    hasTime: (map['has_time'] as int? ?? 1) == 1,
    repeatDays: (map['repeat_days'] as String)
        .split(',')
        .where((value) => value.isNotEmpty)
        .map(int.parse)
        .toSet(),
    startDate: DateTime.parse(map['start_date'] as String),
    endDate: map['end_date'] == null
        ? null
        : DateTime.parse(map['end_date'] as String),
    isActive: (map['is_active'] as int? ?? 1) == 1,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
