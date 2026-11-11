import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_todolist_app/model/todo.dart';
import 'package:simple_todolist_app/repository/todo_repository.dart';
import 'package:simple_todolist_app/view/home.dart';

class MemoryTodoRepository implements TodoRepository {
  final List<TodoItem> todos = [];
  final List<DeletedTodoItem> deletedTodos = [];
  int nextId = 1;
  int nextDeletedId = 1;

  @override
  Future<TodoItem> addTodo(TodoItem todo) async {
    final saved = TodoItem(
      id: nextId++,
      content: todo.content,
      createdDate: todo.createdDate,
    );
    todos.insert(0, saved);
    return saved;
  }

  @override
  Future<void> moveTodoToTrash(int id, String deletedDate) async {
    final todo = todos.singleWhere((todo) => todo.id == id);
    deletedTodos.insert(
      0,
      DeletedTodoItem(
        id: nextDeletedId++,
        content: todo.content,
        createdDate: todo.createdDate,
        deletedDate: deletedDate,
      ),
    );
    todos.remove(todo);
  }

  @override
  Future<List<TodoItem>> getTodos() async => List.of(todos);

  @override
  Future<List<DeletedTodoItem>> getDeletedTodos() async =>
      List.of(deletedTodos);

  @override
  Future<void> permanentlyDeleteTodo(int id) async {
    deletedTodos.removeWhere((todo) => todo.id == id);
  }

  @override
  Future<void> restoreTodo(int id) async {
    final deletedTodo = deletedTodos.singleWhere((todo) => todo.id == id);
    todos.insert(
      0,
      TodoItem(
        id: nextId++,
        content: deletedTodo.content,
        createdDate: deletedTodo.createdDate,
      ),
    );
    deletedTodos.remove(deletedTodo);
  }

  @override
  Future<void> emptyTrash() async => deletedTodos.clear();

  @override
  Future<void> updateTodoOrder(List<int> orderedIds) async {
    final todosById = {for (final todo in todos) todo.id!: todo};
    todos
      ..clear()
      ..addAll(orderedIds.map((id) => todosById[id]!));
  }
}

void main() {
  testWidgets('BottomSheet로 Todo를 추가하고 스와이프로 삭제한다', (tester) async {
    final repository = MemoryTodoRepository();

    await tester.pumpWidget(MaterialApp(home: Home(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Todo Lists'), findsOneWidget);
    expect(find.text('아직 등록된 할 일이 없어요'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open_add_dialog')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('todo_input')), 'Flutter 공부');
    await tester.pump();
    await tester.tap(find.byKey(const Key('add_todo_button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Flutter 공부'), findsOneWidget);
    expect(repository.todos, hasLength(1));
    expect(
      repository.todos.single.createdDate,
      matches(r'^\d{4}-\d{2}-\d{2}$'),
    );

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('Flutter 공부'), findsNothing);
    expect(repository.todos, isEmpty);
    expect(repository.deletedTodos, hasLength(1));

    await tester.tap(find.byKey(const Key('open_trash_button')));
    await tester.pumpAndSettle();
    expect(find.text('휴지통'), findsOneWidget);
    expect(find.text('Flutter 공부'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_permanent_delete')));
    await tester.pumpAndSettle();

    expect(repository.deletedTodos, isEmpty);
    expect(find.text('휴지통이 비어 있어요'), findsOneWidget);
  });

  testWidgets('휴지통 항목을 오른쪽으로 스와이프하면 Todo로 복구한다', (tester) async {
    final repository = MemoryTodoRepository()
      ..deletedTodos.add(
        const DeletedTodoItem(
          id: 1,
          content: '복구할 항목',
          createdDate: '2026-08-26',
          deletedDate: '2026-08-26',
        ),
      );

    await tester.pumpWidget(MaterialApp(home: Home(repository: repository)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_trash_button')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(repository.deletedTodos, isEmpty);
    expect(repository.todos.single.content, '복구할 항목');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('복구할 항목'), findsOneWidget);
  });

  testWidgets('드래그 핸들로 Todo 순서를 변경하고 저장한다', (tester) async {
    final repository = MemoryTodoRepository()
      ..todos.addAll(const [
        TodoItem(id: 1, content: '첫 번째', createdDate: '2026-08-26'),
        TodoItem(id: 2, content: '두 번째', createdDate: '2026-08-26'),
      ]);

    await tester.pumpWidget(MaterialApp(home: Home(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drag-1')), findsOneWidget);
    final reorderableList = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    reorderableList.onReorderItem!(0, 1);
    await tester.pumpAndSettle();

    expect(repository.todos.map((todo) => todo.id), [2, 1]);
  });

  testWidgets('휴지통 비우기로 모든 삭제 항목을 영구 삭제한다', (tester) async {
    final repository = MemoryTodoRepository()
      ..deletedTodos.addAll(const [
        DeletedTodoItem(
          id: 1,
          content: '삭제 항목 1',
          createdDate: '2026-08-26',
          deletedDate: '2026-08-26',
        ),
        DeletedTodoItem(
          id: 2,
          content: '삭제 항목 2',
          createdDate: '2026-08-26',
          deletedDate: '2026-08-26',
        ),
      ]);

    await tester.pumpWidget(MaterialApp(home: Home(repository: repository)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_trash_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('empty_trash_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_permanent_delete')));
    await tester.pumpAndSettle();

    expect(repository.deletedTodos, isEmpty);
    expect(find.text('휴지통이 비어 있어요'), findsOneWidget);
  });
}
