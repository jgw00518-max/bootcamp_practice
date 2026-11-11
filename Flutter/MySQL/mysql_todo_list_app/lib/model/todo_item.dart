/// 현재 Todo 목록에 표시하는 한 항목이다.
class TodoItem {
  const TodoItem({
    required this.seq,
    required this.title,
    required this.todoDate,
  });

  final int seq;
  final String title;
  final String todoDate;

  /// FastAPI가 반환한 JSON을 화면 모델로 변환한다.
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      seq: json['seq'] as int,
      title: json['title'] as String? ?? '',
      todoDate: json['todo_date'] as String? ?? '',
    );
  }
}

/// 삭제 목록에 보관된 Todo와 삭제 정보를 나타낸다.
class DeletedTodoItem extends TodoItem {
  const DeletedTodoItem({
    required super.seq,
    required super.title,
    required super.todoDate,
    required this.todoSeq,
    required this.deleteTime,
  });

  final int? todoSeq;
  final String deleteTime;

  /// 삭제 Todo JSON을 화면 모델로 변환한다.
  factory DeletedTodoItem.fromJson(Map<String, dynamic> json) {
    return DeletedTodoItem(
      seq: json['seq'] as int,
      todoSeq: json['todo_seq'] as int?,
      title: json['title'] as String? ?? '',
      todoDate: json['todo_date'] as String? ?? '',
      deleteTime: json['delete_time'] as String? ?? '',
    );
  }
}
