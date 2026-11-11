/// 데이터베이스와 화면 사이에서 사용하는 할 일 데이터 모델이다.
class TodoItem {
  const TodoItem({this.id, required this.content, required this.createdDate});

  /// 데이터베이스에서 자동으로 생성되는 할 일의 고유 번호다.
  final int? id;

  /// 사용자가 입력한 할 일 내용이다.
  final String content;

  /// 할 일을 등록한 날짜이며 `yyyy-MM-dd` 형식으로 저장된다.
  final String createdDate;

  /// [TodoItem]을 SQLite에 저장할 수 있는 Map으로 변환한다.
  Map<String, Object?> toMap() => {
    'id': id,
    'content': content,
    'created_date': createdDate,
  };

  /// SQLite 조회 결과를 [TodoItem] 객체로 변환한다.
  factory TodoItem.fromMap(Map<String, Object?> map) => TodoItem(
    id: map['id'] as int,
    content: map['content'] as String,
    createdDate: map['created_date'] as String,
  );
}

/// 휴지통 테이블에 보관된 삭제 항목 모델이다.
class DeletedTodoItem {
  const DeletedTodoItem({
    required this.id,
    required this.content,
    required this.createdDate,
    required this.deletedDate,
  });

  final int id;
  final String content;
  final String createdDate;
  final String deletedDate;

  /// SQLite 조회 결과를 [DeletedTodoItem]로 변환한다.
  factory DeletedTodoItem.fromMap(Map<String, Object?> map) => DeletedTodoItem(
    id: map['id'] as int,
    content: map['content'] as String,
    createdDate: map['created_date'] as String,
    deletedDate: map['deleted_date'] as String,
  );
}
