/// 사용자가 할 일과 루틴에 지정할 수 있는 카테고리입니다.
class TodoCategory {
  const TodoCategory({required this.id, required this.name, this.color});

  final int id;
  final String name;
  final int? color;

  factory TodoCategory.fromMap(Map<String, Object?> map) => TodoCategory(
    id: map['id'] as int,
    name: map['name'] as String,
    color: map['color'] as int?,
  );
}
