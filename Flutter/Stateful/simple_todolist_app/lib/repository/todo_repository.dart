import '../model/todo.dart';

/// 화면과 데이터 저장 구현 사이의 Todo 데이터 계약이다.
abstract interface class TodoRepository {
  Future<List<TodoItem>> getTodos();
  Future<TodoItem> addTodo(TodoItem todo);
  Future<void> moveTodoToTrash(int id, String deletedDate);
  Future<List<DeletedTodoItem>> getDeletedTodos();
  Future<void> permanentlyDeleteTodo(int id);
  Future<void> restoreTodo(int id);
  Future<void> emptyTrash();
  Future<void> updateTodoOrder(List<int> orderedIds);
}
