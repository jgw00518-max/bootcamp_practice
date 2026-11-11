/// SQLite와 화면 사이에서 할 일 데이터를 전달합니다.
class Todo {
  const Todo({
    this.id,
    required this.title,
    this.memo = '',
    required this.dueAt,
    this.hasTime = true,
    this.category = '없음',
    this.categoryId,
    this.priority = 1,
    this.estimatedMinutes = 30,
    this.isCompleted = false,
    this.routineId,
    this.routineDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String memo;
  final DateTime dueAt;
  final bool hasTime;
  final String category;
  final int? categoryId;
  final int priority;
  final int estimatedMinutes;
  final bool isCompleted;
  final int? routineId;
  final DateTime? routineDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Todo copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) => Todo(
    id: id,
    title: title,
    memo: memo,
    dueAt: dueAt,
    hasTime: hasTime,
    category: category,
    categoryId: categoryId,
    priority: priority,
    estimatedMinutes: estimatedMinutes,
    isCompleted: isCompleted ?? this.isCompleted,
    routineId: routineId,
    routineDate: routineDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
    completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'memo': memo,
    'due_at': dueAt.toIso8601String(),
    'has_time': hasTime ? 1 : 0,
    'category': category,
    'category_id': categoryId,
    'priority': priority,
    'estimated_minutes': estimatedMinutes,
    'is_completed': isCompleted ? 1 : 0,
    'routine_id': routineId,
    'routine_date': routineDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };

  factory Todo.fromMap(Map<String, Object?> map) => Todo(
    id: map['id'] as int,
    title: map['title'] as String,
    memo: map['memo'] as String? ?? '',
    dueAt: DateTime.parse(map['due_at'] as String),
    hasTime: (map['has_time'] as int? ?? 1) == 1,
    category: map['category'] as String? ?? '없음',
    categoryId: map['category_id'] as int?,
    priority: map['priority'] as int? ?? 1,
    estimatedMinutes: map['estimated_minutes'] as int? ?? 30,
    isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    routineId: map['routine_id'] as int?,
    routineDate: map['routine_date'] == null
        ? null
        : DateTime.parse(map['routine_date'] as String),
    createdAt: map['created_at'] == null
        ? null
        : DateTime.parse(map['created_at'] as String),
    updatedAt: map['updated_at'] == null
        ? null
        : DateTime.parse(map['updated_at'] as String),
    completedAt: map['completed_at'] == null
        ? null
        : DateTime.parse(map['completed_at'] as String),
  );

  /// 시간이 없는 일정은 선택한 날짜가 끝날 때까지 완료할 수 있습니다.
  DateTime get deadlineAt => hasTime
      ? dueAt
      : DateTime(dueAt.year, dueAt.month, dueAt.day, 23, 59, 59, 999);
}

/// 휴지통에 이동된 Todo와 삭제 시각을 함께 전달합니다.
class DeletedTodo {
  const DeletedTodo({required this.todo, required this.deletedAt});

  final Todo todo;
  final DateTime deletedAt;

  factory DeletedTodo.fromMap(Map<String, Object?> map) => DeletedTodo(
    todo: Todo.fromMap(map),
    deletedAt: DateTime.parse(map['deleted_at'] as String),
  );
}
