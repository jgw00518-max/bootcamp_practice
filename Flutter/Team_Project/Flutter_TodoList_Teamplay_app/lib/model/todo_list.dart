class TodoList {
  // Properties
  String todoText;  // 할 일
  String date;      // 날짜
  String time;      // 시간
  String category;  // 카테고리
  bool isImportant; // 중요 여부
  bool isCompleted; // 완료 여부

  // Constructor
  TodoList({
    required this.todoText,
    required this.date,
    required this.time,
    required this.category,
    required this.isImportant,
    required this.isCompleted,
  });

  // 객체 -> 단일 문자열 변환
  String toRawString() {
    return '$todoText|$date|$time|$category|$isImportant|$isCompleted';
  }

  // 단일 문자열 -> 객체 변환 (factory 생성자)
  factory TodoList.fromRawString(String raw) {
    List<String> parts = raw.split('|');
    return TodoList(
      todoText: parts[0],
      date: parts[1],
      time: parts[2],
      category: parts[3],
      isImportant: parts[4] == 'true',
      isCompleted: parts[5] == 'true',
    );
  }
}