import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/data/todo_database.dart';
import 'package:project_todolist/main.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/model/todo_category.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/work_session.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/category_management_page.dart';

class _MemoryTodoRepository implements TodoRepository {
  @override
  Future<void> seedExamplesIfNeeded(DateTime today) async {}

  bool failReads = false;
  bool failWrites = false;
  int readTodosCount = 0;
  Completer<void>? readTodosGate;
  final List<DeletedTodo> deletedValues = [];
  final List<WorkSession> sessionValues = [];
  final List<Routine> routineValues = [];
  final List<TodoCategory> categoryValues = const [
    TodoCategory(id: 1, name: '업무'),
    TodoCategory(id: 2, name: '개인'),
    TodoCategory(id: 3, name: '건강'),
    TodoCategory(id: 4, name: '학습'),
  ].toList();
  final List<Todo> values = [
    Todo(
      id: 1,
      title: '테스트 할 일',
      memo: '중요 보고서 작성',
      dueAt: DateTime.now().add(const Duration(hours: 1)),
      priority: 2,
      createdAt: DateTime.now(),
    ),
    Todo(
      id: 2,
      title: '완료 운동',
      dueAt: DateTime.now(),
      category: '건강',
      priority: 0,
      isCompleted: true,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ),
    Todo(
      id: 3,
      title: '내일 장보기',
      dueAt: DateTime.now().add(const Duration(days: 1)),
      category: '개인',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<int> insert(Todo todo) async {
    if (failWrites) throw StateError('write failed');
    final id = values.length + 1;
    values.add(
      Todo(
        id: id,
        title: todo.title,
        memo: todo.memo,
        dueAt: todo.dueAt,
        hasTime: todo.hasTime,
        category: todo.category,
        categoryId: todo.categoryId,
        priority: todo.priority,
        estimatedMinutes: todo.estimatedMinutes,
        isCompleted: todo.isCompleted,
        routineId: todo.routineId,
        routineDate: todo.routineDate,
        createdAt: todo.createdAt ?? DateTime.now(),
        updatedAt: todo.updatedAt,
        completedAt: todo.completedAt,
      ),
    );
    return id;
  }

  @override
  Future<List<Todo>> readTodos() async {
    readTodosCount++;
    await readTodosGate?.future;
    if (failReads) throw StateError('read failed');
    return List.of(values);
  }

  @override
  Future<List<TodoCategory>> readCategories() async => List.of(categoryValues);

  @override
  Future<int> insertCategory(String name) async {
    if (failWrites) throw StateError('write failed');
    final id = categoryValues.isEmpty
        ? 1
        : categoryValues
                  .map((item) => item.id)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    categoryValues.add(TodoCategory(id: id, name: name));
    return id;
  }

  @override
  Future<void> updateCategory(int id, String name) async {
    final index = categoryValues.indexWhere((item) => item.id == id);
    final oldName = categoryValues[index].name;
    categoryValues[index] = TodoCategory(id: id, name: name);
    _replaceCategory(oldName, name, id);
  }

  @override
  Future<void> deleteCategory(int id) async {
    final category = categoryValues.firstWhere((item) => item.id == id);
    categoryValues.remove(category);
    _replaceCategory(category.name, '없음', null);
  }

  void _replaceCategory(String oldName, String newName, int? categoryId) {
    for (var index = 0; index < values.length; index++) {
      final todo = values[index];
      if (todo.category != oldName) continue;
      values[index] = Todo(
        id: todo.id,
        title: todo.title,
        memo: todo.memo,
        dueAt: todo.dueAt,
        hasTime: todo.hasTime,
        category: newName,
        categoryId: categoryId,
        priority: todo.priority,
        estimatedMinutes: todo.estimatedMinutes,
        isCompleted: todo.isCompleted,
        routineId: todo.routineId,
        routineDate: todo.routineDate,
        createdAt: todo.createdAt,
        updatedAt: todo.updatedAt,
        completedAt: todo.completedAt,
      );
    }
    for (var index = 0; index < routineValues.length; index++) {
      final routine = routineValues[index];
      if (routine.category != oldName) continue;
      routineValues[index] = Routine(
        id: routine.id,
        title: routine.title,
        memo: routine.memo,
        category: newName,
        categoryId: categoryId,
        priority: routine.priority,
        estimatedMinutes: routine.estimatedMinutes,
        scheduledHour: routine.scheduledHour,
        scheduledMinute: routine.scheduledMinute,
        hasTime: routine.hasTime,
        repeatDays: routine.repeatDays,
        startDate: routine.startDate,
        endDate: routine.endDate,
        isActive: routine.isActive,
        createdAt: routine.createdAt,
      );
    }
  }

  @override
  Future<List<Todo>> readAnalyticsTodos() async => [
    ...values,
    ...deletedValues.map((item) => item.todo),
  ];

  @override
  Future<List<DeletedTodo>> readDeletedTodos() async => List.of(deletedValues);

  @override
  Future<List<WorkSession>> readWorkSessions() async => List.of(sessionValues);

  @override
  Future<void> normalizeActiveWorkSessions() async {
    final active =
        sessionValues.where((session) => !session.isCompleted).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    for (final session in active.skip(1)) {
      final index = sessionValues.indexWhere((value) => value.id == session.id);
      sessionValues[index] = session.copyWith(
        status: WorkSessionStatus.completed,
        clearEndsAt: true,
        clearPausedAt: true,
        completedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> update(Todo todo) async {
    final index = values.indexWhere((value) => value.id == todo.id);
    values[index] = todo;
  }

  @override
  Future<void> setTodoCompletion(int id, {required bool isCompleted}) async {
    final index = values.indexWhere((todo) => todo.id == id);
    final todo = values[index];
    values[index] = todo.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      clearCompletedAt: !isCompleted,
    );
  }

  @override
  Future<void> moveToTrash(int id) async {
    final now = DateTime.now();
    for (var index = 0; index < sessionValues.length; index++) {
      final session = sessionValues[index];
      if (session.todoId != id || session.isCompleted) continue;
      sessionValues[index] = session.copyWith(
        elapsedSeconds: session.isRunning
            ? session.elapsedAt(now)
            : session.elapsedSeconds,
        status: WorkSessionStatus.completed,
        clearEndsAt: true,
        clearPausedAt: true,
        completedAt: now,
      );
    }
    final todo = values.firstWhere((todo) => todo.id == id);
    values.remove(todo);
    deletedValues.add(DeletedTodo(todo: todo, deletedAt: DateTime.now()));
  }

  @override
  Future<void> restoreTodo(int id) async {
    final item = deletedValues.firstWhere((item) => item.todo.id == id);
    deletedValues.remove(item);
    values.add(item.todo);
    values.sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  @override
  Future<void> restoreAllTodos() async {
    values.addAll(deletedValues.map((item) => item.todo));
    deletedValues.clear();
    values.sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  @override
  Future<void> permanentlyDeleteTodo(int id) async {
    deletedValues.removeWhere((item) => item.todo.id == id);
  }

  @override
  Future<void> permanentlyDeleteAllTodos() async => deletedValues.clear();

  @override
  Future<int> insertWorkSession(WorkSession session) async {
    final id = sessionValues.length + 1;
    sessionValues.add(session.copyWith(id: id));
    return id;
  }

  @override
  Future<void> updateWorkSession(WorkSession session) async {
    final index = sessionValues.indexWhere((value) => value.id == session.id);
    sessionValues[index] = session;
  }

  @override
  Future<List<Routine>> readRoutines() async => List.of(routineValues);

  @override
  Future<int> insertRoutine(Routine routine) async {
    final id = routineValues.length + 1;
    routineValues.add(
      Routine(
        id: id,
        title: routine.title,
        memo: routine.memo,
        category: routine.category,
        categoryId: routine.categoryId,
        priority: routine.priority,
        estimatedMinutes: routine.estimatedMinutes,
        scheduledHour: routine.scheduledHour,
        scheduledMinute: routine.scheduledMinute,
        hasTime: routine.hasTime,
        repeatDays: routine.repeatDays,
        startDate: routine.startDate,
        endDate: routine.endDate,
        isActive: routine.isActive,
        createdAt: routine.createdAt,
      ),
    );
    return id;
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    final index = routineValues.indexWhere((value) => value.id == routine.id);
    routineValues[index] = routine;
  }

  @override
  Future<void> deleteRoutine(
    int id, {
    required bool moveIncompleteTodosToTrash,
  }) async {
    if (moveIncompleteTodosToTrash) {
      final ids = values
          .where((todo) => todo.routineId == id && todo.completedAt == null)
          .map((todo) => todo.id!)
          .toList();
      for (final todoId in ids) {
        await moveToTrash(todoId);
      }
    }
    routineValues.removeWhere((routine) => routine.id == id);
  }

  @override
  Future<void> createRoutineTodosFor(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    for (final routine in routineValues.where((item) => item.appliesTo(day))) {
      final exists = values.any(
        (todo) =>
            todo.routineId == routine.id &&
            todo.routineDate?.year == day.year &&
            todo.routineDate?.month == day.month &&
            todo.routineDate?.day == day.day,
      );
      final wasDeleted = deletedValues.any(
        (item) =>
            item.todo.routineId == routine.id &&
            item.todo.routineDate?.year == day.year &&
            item.todo.routineDate?.month == day.month &&
            item.todo.routineDate?.day == day.day,
      );
      if (exists || wasDeleted) continue;
      await insert(
        Todo(
          title: routine.title,
          memo: routine.memo,
          dueAt: DateTime(
            day.year,
            day.month,
            day.day,
            routine.scheduledHour,
            routine.scheduledMinute,
          ),
          category: routine.category,
          categoryId: routine.categoryId,
          priority: routine.priority,
          estimatedMinutes: routine.estimatedMinutes,
          hasTime: routine.hasTime,
          routineId: routine.id,
          routineDate: day,
        ),
      );
    }
  }

  @override
  Future<void> syncRoutineTodos(DateTime today) async {
    final currentDay = DateUtils.dateOnly(today);
    await createRoutineTodosFor(currentDay);
  }
}

void main() {
  late _MemoryTodoRepository repository;

  setUpAll(() => initializeDateFormatting('ko_KR'));

  setUp(() async {
    Get.testMode = true;
    repository = _MemoryTodoRepository();
    final controller = Get.put(TodoController(repository));
    await controller.loadTodos();
  });

  tearDown(Get.reset);

  test('검색 및 필터 결과에 선택한 정렬을 적용한다', () async {
    repository.values
      ..clear()
      ..addAll([
        Todo(
          id: 1,
          title: '나 일정',
          dueAt: DateTime(2030, 1, 2),
          priority: 0,
          createdAt: DateTime(2029, 1, 1),
        ),
        Todo(
          id: 2,
          title: '가 일정',
          dueAt: DateTime(2030, 1, 3),
          priority: 1,
          createdAt: DateTime(2029, 1, 3),
        ),
        Todo(
          id: 3,
          title: '다 일정',
          dueAt: DateTime(2030, 1, 1),
          priority: 2,
          routineId: 10,
          createdAt: DateTime(2029, 1, 2),
        ),
      ]);
    final controller = Get.find<TodoController>();
    await controller.loadTodos();
    controller.statusFilter.value = TodoStatusFilter.all;

    List<int?> sortedIds() =>
        controller.filteredTodos.map((todo) => todo.id).toList();

    expect(sortedIds(), [3, 1, 2]);
    controller.todoSortOption.value = TodoSortOption.newest;
    expect(sortedIds(), [2, 3, 1]);
    controller.todoSortOption.value = TodoSortOption.title;
    expect(sortedIds(), [2, 1, 3]);
    controller.todoSortOption.value = TodoSortOption.priority;
    expect(sortedIds(), [3, 2, 1]);
    controller.todoTypeFilter.value = TodoTypeFilter.normal;
    expect(sortedIds(), [2, 1]);
    controller.todoTypeFilter.value = TodoTypeFilter.routine;
    expect(sortedIds(), [3]);
  });

  testWidgets('카테고리를 추가하고 이름을 수정한 뒤 삭제한다', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: CategoryManagementPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('없음'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add_category_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('category_name_field')),
      '여행',
    );
    await tester.tap(find.byKey(const ValueKey('save_category_button')));
    await tester.pumpAndSettle();
    expect(find.text('여행'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit_category_여행')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('category_name_field')),
      '취미',
    );
    await tester.tap(find.byKey(const ValueKey('save_category_button')));
    await tester.pumpAndSettle();
    expect(find.text('취미'), findsOneWidget);
    expect(find.text('여행'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('add_category_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('category_name_field')),
      '취미',
    );
    await tester.tap(find.byKey(const ValueKey('save_category_button')));
    await tester.pump();
    expect(find.text('이미 사용 중인 카테고리 이름입니다.'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('delete_category_취미')));
    await tester.pumpAndSettle();
    expect(find.text('연결된 할 일을 카테고리 없음으로 변경하고 삭제합니다.'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('confirm_delete_category_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('취미'), findsNothing);
  });

  testWidgets('카테고리 관리는 선택값으로 저장하지 않고 관리 화면만 연다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '카테고리 선택 확인',
    );
    final formScroll = find
        .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('todo_details_toggle')),
      160,
      scrollable: formScroll,
    );
    await tester.drag(formScroll, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('todo_details_toggle')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('todo_category_field')),
      160,
      scrollable: formScroll,
    );
    await tester.drag(formScroll, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카테고리 관리').last);
    await tester.pumpAndSettle();

    expect(find.text('카테고리 관리'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    final categoryField = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(categoryField.initialValue, '없음');

    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pumpAndSettle();
    final saved = Get.find<TodoController>().todos.firstWhere(
      (todo) => todo.title == '카테고리 선택 확인',
    );
    expect(saved.category, '없음');
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  test('미래 루틴은 Todo를 만들지 않고 캘린더 예정 항목으로 계산한다', () async {
    repository.values.clear();
    final now = DateTime.now();
    await repository.insertRoutine(
      Routine(
        title: '매일 계획 확인',
        category: '업무',
        priority: 2,
        scheduledHour: 9,
        scheduledMinute: 30,
        repeatDays: const {1, 2, 3, 4, 5, 6, 7},
        startDate: now,
        createdAt: now,
      ),
    );
    final controller = Get.find<TodoController>();
    await controller.loadTodos();
    final tomorrow = DateUtils.dateOnly(now).add(const Duration(days: 1));

    expect(controller.todos, hasLength(1));
    expect(controller.calendarRoutinePreviewsFor(tomorrow), hasLength(1));

    controller.calendarStatusFilter.value = CalendarStatusFilter.completed;
    expect(controller.calendarRoutinePreviewsFor(tomorrow), isEmpty);
    controller.calendarStatusFilter.value = CalendarStatusFilter.all;
    controller.calendarTodoTypeFilter.value = CalendarTodoTypeFilter.normal;
    expect(controller.calendarRoutinePreviewsFor(tomorrow), isEmpty);
    controller.calendarTodoTypeFilter.value = CalendarTodoTypeFilter.routine;
    expect(controller.calendarRoutinePreviewsFor(tomorrow), hasLength(1));
  });

  test('시간 없는 오늘 일정은 날짜가 끝난 뒤에만 기한이 지난다', () {
    final controller = Get.find<TodoController>();
    final todo = Todo(
      id: 99,
      title: '오늘 안에 완료',
      dueAt: DateTime(2026, 9, 3),
      hasTime: false,
    );

    controller.currentTime.value = DateTime(2026, 9, 3, 23, 30);
    expect(controller.isTodoOverdue(todo), isFalse);
    controller.currentTime.value = DateTime(2026, 9, 4);
    expect(controller.isTodoOverdue(todo), isTrue);
  });

  test('저장된 Todo가 없으면 예시 데이터를 자동 생성하지 않는다', () async {
    repository.values.clear();

    await Get.find<TodoController>().loadTodos();

    expect(repository.values, isEmpty);
    expect(Get.find<TodoController>().todos, isEmpty);
  });

  testWidgets('전체 목록이 비면 첫 할 일 등록 안내만 표시한다', (tester) async {
    repository.values.clear();
    await Get.find<TodoController>().loadTodos();

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(find.text('아직 등록된 할 일이 없어요'), findsOneWidget);
    expect(find.text('+ 버튼을 눌러 첫 할 일을 추가해 보세요'), findsOneWidget);
    expect(find.byKey(const ValueKey('reset_filters_button')), findsNothing);
    expect(find.byKey(const ValueKey('todo_search_field')), findsNothing);
    expect(find.byKey(const ValueKey('add_todo_button')), findsOneWidget);
  });

  testWidgets('DB 읽기 실패 시 기존 데이터를 유지하고 다시 시도한다', (tester) async {
    final controller = Get.find<TodoController>();
    repository.failReads = true;

    expect(await controller.loadTodos(), isFalse);
    expect(controller.todos, hasLength(3));
    await tester.pumpWidget(const TodoApp());
    await tester.pump();

    expect(find.text('데이터를 불러오지 못했습니다.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('retry_load_todos_button')),
      findsOneWidget,
    );

    repository.failReads = false;
    await tester.tap(find.byKey(const ValueKey('retry_load_todos_button')));
    await tester.pumpAndSettle();

    expect(controller.loadError.value, isNull);
    expect(controller.todos, hasLength(3));
  });

  testWidgets('Todo 저장 실패 시 입력 화면을 닫지 않는다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '저장 실패 확인',
    );
    repository.failWrites = true;

    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pump();

    expect(find.byKey(const ValueKey('todo_title_field')), findsOneWidget);
    expect(repository.values, hasLength(3));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('저장 후 재조회 실패를 성공으로 처리하지 않는다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '재조회 실패 확인',
    );
    repository.failReads = true;

    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pump();

    expect(repository.values.map((todo) => todo.title), contains('재조회 실패 확인'));
    expect(find.byKey(const ValueKey('todo_title_field')), findsOneWidget);
    expect(find.text('저장은 완료했어요'), findsOneWidget);
    expect(Get.find<TodoController>().loadError.value, isNotNull);
    repository.failReads = false;
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  test('동시에 요청한 전체 조회를 합치고 마지막 갱신만 한 번 실행한다', () async {
    final controller = Get.find<TodoController>();
    final countBefore = repository.readTodosCount;
    repository.readTodosGate = Completer<void>();

    final first = controller.loadTodos();
    while (repository.readTodosCount == countBefore) {
      await Future<void>.delayed(Duration.zero);
    }
    final second = controller.loadTodos();
    final third = controller.loadTodos();
    repository.readTodosGate!.complete();

    expect(await Future.wait([first, second, third]), everyElement(isTrue));
    expect(repository.readTodosCount, countBefore + 2);
  });

  test('휴지통 Todo는 과거 통계에 유지하고 영구 삭제 시 집계에서 제외한다', () async {
    final controller = Get.find<TodoController>();
    final completedBefore = controller
        .weeklyCompletedCountsFor(0)
        .fold(0, (sum, value) => sum + value);

    await controller.moveToTrash(2);

    expect(controller.todos.any((todo) => todo.id == 2), isFalse);
    expect(controller.categoryCompletionStats['건강']?.total, 1);
    expect(controller.categoryCompletionStats['건강']?.completed, 1);
    expect(
      controller
          .weeklyCompletedCountsFor(0)
          .fold(0, (sum, value) => sum + value),
      completedBefore,
    );

    await controller.permanentlyDeleteTodo(2);

    expect(controller.categoryCompletionStats.containsKey('건강'), isFalse);
  });

  test('집중 시작을 연속 요청해도 활성 세션은 하나만 생성한다', () async {
    final controller = Get.find<TodoController>();

    await Future.wait([
      controller.startFocus(todoId: 1, plannedSeconds: 600),
      controller.startFocus(todoId: 1, plannedSeconds: 600),
    ]);

    expect(repository.sessionValues, hasLength(1));
    expect(controller.activeWorkSession.value, isNotNull);
    expect(controller.isStartingFocus.value, isFalse);
  });

  test('여러 활성 세션이 있으면 앱 로딩 시 최신 세션만 유지한다', () async {
    final now = DateTime.now();
    repository.sessionValues.addAll([
      WorkSession(
        id: 1,
        todoId: 1,
        plannedSeconds: 600,
        elapsedSeconds: 100,
        startedAt: now.subtract(const Duration(minutes: 10)),
        status: WorkSessionStatus.paused,
      ),
      WorkSession(
        id: 2,
        todoId: 3,
        plannedSeconds: 600,
        elapsedSeconds: 0,
        startedAt: now,
        status: WorkSessionStatus.running,
        endsAt: now.add(const Duration(minutes: 10)),
      ),
    ]);

    final controller = Get.find<TodoController>();
    await controller.loadTodos();

    expect(
      repository.sessionValues.where((session) => !session.isCompleted),
      hasLength(1),
    );
    expect(controller.activeWorkSession.value?.id, 2);
  });

  testWidgets('집중 중인 Todo를 삭제하면 시간을 저장하고 세션을 종료한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();
    await controller.startFocus(todoId: 1, plannedSeconds: 600);
    await tester.pump();

    await tester.drag(
      find.byKey(const ValueKey('todo_card_1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slide_delete_1')));
    await tester.pumpAndSettle();

    expect(find.text('집중을 종료하고 삭제할까요?'), findsOneWidget);
    expect(find.text('현재까지의 집중 시간을 저장한 후 휴지통으로 이동합니다.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm_delete_button')));
    await tester.pumpAndSettle();

    expect(controller.activeWorkSession.value, isNull);
    expect(repository.sessionValues.single.isCompleted, isTrue);
    expect(repository.sessionValues.single.completedAt, isNotNull);
    expect(controller.deletedTodos.single.todo.id, 1);

    await controller.restoreTodo(1);
    expect(controller.todos.any((todo) => todo.id == 1), isTrue);
    expect(repository.sessionValues.single.todoId, 1);
  });

  test('루틴 삭제 시 미완료 일정만 휴지통으로 보내고 완료 기록은 유지한다', () async {
    final controller = Get.find<TodoController>();
    repository.routineValues.add(
      Routine(
        id: 10,
        title: '삭제할 루틴',
        scheduledHour: 9,
        scheduledMinute: 0,
        repeatDays: {1},
        startDate: DateTime(2026, 9, 1),
        createdAt: DateTime(2026, 9, 1),
      ),
    );
    repository.values
      ..clear()
      ..addAll([
        Todo(
          id: 10,
          title: '미완료 루틴 일정',
          dueAt: DateTime(2026, 9, 3, 9),
          routineId: 10,
        ),
        Todo(
          id: 11,
          title: '완료 루틴 일정',
          dueAt: DateTime(2026, 9, 2, 9),
          routineId: 10,
          isCompleted: true,
          completedAt: DateTime(2026, 9, 2, 8),
        ),
      ]);
    await controller.loadTodos();

    expect(
      await controller.deleteRoutine(10, moveIncompleteTodosToTrash: true),
      isTrue,
    );

    expect(controller.routines, isEmpty);
    expect(controller.todos.map((todo) => todo.id), [11]);
    expect(controller.deletedTodos.map((item) => item.todo.id), contains(10));
    expect(
      controller.deletedTodos.every((item) => item.todo.routineId == 10),
      isTrue,
    );
  });

  testWidgets('오늘 목록을 표시하고 추가 화면으로 이동한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(Get.find<TodoController>().todos, hasLength(3));
    expect(Get.find<TodoController>().filteredTodos, isNotEmpty);
    expect(find.text('안녕하세요, 오늘도 파이팅! 👋'), findsOneWidget);
    expect(find.text('테스트 할 일'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('todo_1'))),
      const Size(48, 48),
    );
    expect(find.byKey(const ValueKey('todo_memo_indicator_1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('completed_section_toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('todo_memo_indicator_2')), findsNothing);
    final completedMetadata = tester.widget<Text>(
      find.byKey(const ValueKey('todo_metadata_2')),
    );
    expect(completedMetadata.style?.color?.a, lessThan(1));

    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();

    expect(find.text('새 할 일'), findsOneWidget);
    expect(find.byKey(const ValueKey('todo_title_field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('close_task_form_button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('save_todo_button')), findsOneWidget);
  });

  testWidgets('할 일 완료 실행 취소 안내는 3초 후 사라진다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('todo_1')));
    await tester.pump();
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 3));
    expect(find.text('할 일을 완료했어요.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('할 일을 완료했어요.'), findsNothing);
  });

  testWidgets('완료 목록을 기본으로 접고 필요할 때 펼치거나 검색한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('completed_section_toggle')),
      findsOneWidget,
    );
    expect(find.text('펼치기'), findsOneWidget);
    expect(find.text('완료 운동'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('completed_section_toggle')));
    await tester.pump();
    expect(find.text('접기'), findsOneWidget);
    expect(find.text('완료 운동'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('completed_section_toggle')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('todo_search_field')),
      '완료 운동',
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('todo_card_2')), findsOneWidget);
  });

  testWidgets('같은 날짜라도 시간이 지나면 기한이 지난 목록으로 이동한다', (tester) async {
    final controller = Get.find<TodoController>();
    final dueAt = DateTime(2030, 1, 15, 10);
    repository.values.add(Todo(id: 99, title: '시간이 지난 일정', dueAt: dueAt));
    await controller.loadTodos();
    controller.currentTime.value = dueAt.add(const Duration(minutes: 1));

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(find.text('기한이 지난 할 일'), findsOneWidget);
    expect(find.text('시간이 지난 일정'), findsOneWidget);
    expect(
      controller.isTodoOverdue(
        controller.todos.firstWhere((todo) => todo.id == 99),
      ),
      isTrue,
    );
  });

  testWidgets('하단 탭 선택 시 filled 아이콘과 강조 스타일을 적용한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    Finder navigationIcon(IconData icon) =>
        find.descendant(of: navigationBar, matching: find.byIcon(icon));

    expect(navigationIcon(Icons.checklist_rounded), findsOneWidget);
    expect(navigationIcon(Icons.calendar_month_outlined), findsOneWidget);

    await tester.tap(navigationIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(navigationIcon(Icons.checklist_outlined), findsOneWidget);
    expect(navigationIcon(Icons.calendar_month_rounded), findsOneWidget);

    final context = tester.element(navigationBar);
    final theme = Theme.of(context);
    final navigationTheme = theme.navigationBarTheme;
    final selectedLabel = navigationTheme.labelTextStyle?.resolve({
      WidgetState.selected,
    });
    final unselectedLabel = navigationTheme.labelTextStyle?.resolve({});

    expect(selectedLabel?.color, AppColors.primary);
    expect(selectedLabel?.fontWeight, FontWeight.w800);
    expect(unselectedLabel?.color, isNot(AppColors.primary));
    expect(navigationTheme.elevation, 4);
    expect(theme.floatingActionButtonTheme.elevation, 4);

    final dialogShape = theme.dialogTheme.shape! as RoundedRectangleBorder;
    final dialogRadius = dialogShape.borderRadius as BorderRadius;
    final sheetShape = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
    final sheetRadius = sheetShape.borderRadius as BorderRadius;
    expect(dialogRadius.topLeft.x, 20);
    expect(sheetRadius.topLeft.x, 24);
    expect(theme.bottomSheetTheme.showDragHandle, isTrue);
    expect(
      theme.filledButtonTheme.style?.backgroundColor?.resolve({}),
      AppColors.primary,
    );
  });

  testWidgets('통계에서 데이터가 없는 우선순위 항목을 숨긴다', (tester) async {
    repository.values.removeWhere((todo) => todo.priority == 1);
    await Get.find<TodoController>().loadTodos();
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('우선순위별 완료율'), 250);

    expect(find.byKey(const ValueKey('priority_rate_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('priority_rate_1')), findsNothing);
    expect(find.byKey(const ValueKey('priority_rate_0')), findsOneWidget);
  });

  testWidgets('좁은 화면과 확대 글자에서도 우선순위를 동일한 폭으로 표시한다', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();
    final formScroll = find
        .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
        .first;
    expect(find.byKey(const ValueKey('todo_memo_field')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('todo_details_toggle')),
      160,
      scrollable: formScroll,
    );
    await tester.drag(formScroll, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('todo_details_toggle')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('높음'),
      160,
      scrollable: formScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('높음'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('낮음'), findsOneWidget);
    expect(find.byKey(const ValueKey('todo_memo_field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('카드에서 기존 할 일을 수정하고 삭제한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('todo_card_1')));
    await tester.pumpAndSettle();

    expect(find.text('할 일 수정'), findsOneWidget);
    final titleField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('todo_title_field')),
    );
    expect(titleField.controller?.text, '테스트 할 일');
    expect(find.byKey(const ValueKey('delete_todo_button')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '수정된 할 일',
    );
    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pumpAndSettle();
    expect(find.text('수정된 할 일'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('todo_card_1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('slide_delete_1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('slide_delete_1')));
    await tester.pumpAndSettle();
    expect(find.text('할 일을 삭제할까요?'), findsOneWidget);
    final deleteButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm_delete_button')),
    );
    final cancelButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '취소'),
    );
    expect(deleteButton.style?.backgroundColor?.resolve({}), AppColors.red);
    expect(cancelButton.style?.foregroundColor?.resolve({}), AppColors.muted);

    await tester.tap(find.byKey(const ValueKey('confirm_delete_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('수정된 할 일'), findsNothing);
    expect(Get.find<TodoController>().deletedTodos, hasLength(1));
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(milliseconds: 2500));
    await tester.tap(find.text('실행 취소'));
    await tester.pumpAndSettle();
    expect(find.text('수정된 할 일'), findsOneWidget);
    expect(Get.find<TodoController>().deletedTodos, isEmpty);
  });

  testWidgets('검색어와 상태·상세 필터를 함께 적용한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('todo_search_field')),
      '중요 보고서',
    );
    await tester.pump();
    expect(find.text('테스트 할 일'), findsOneWidget);
    expect(find.text('완료 운동'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('todo_search_field')),
      '없는 검색어',
    );
    await tester.pump();
    expect(find.text('조건에 맞는 할 일이 없어요'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reset_filters_button')));
    await tester.pump();
    expect(find.text('테스트 할 일'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('status_filter_completed')));
    await tester.pump();
    expect(find.text('완료 운동'), findsOneWidget);
    expect(find.text('테스트 할 일'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('advanced_filter_button')));
    await tester.pumpAndSettle();
    expect(
      find.ancestor(of: find.text('필터 및 정렬'), matching: find.byType(SafeArea)),
      findsOneWidget,
    );
    final filterLabelStyle =
        Theme.of(
              tester.element(find.byKey(const ValueKey('priority_filter_all'))),
            ).chipTheme.labelStyle!
            as WidgetStateTextStyle;
    expect(
      filterLabelStyle.resolve({WidgetState.selected}).color,
      Colors.black,
    );
    expect(filterLabelStyle.resolve({}).color, Colors.black);
    final selectedChoice = tester.widget<ChoiceChip>(
      find.descendant(
        of: find.byKey(const ValueKey('priority_filter_all')),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect((selectedChoice.label as Text).style?.color, Colors.black);
    await tester.tap(find.byKey(const ValueKey('todo_sort_newest')));
    await tester.tap(find.byKey(const ValueKey('priority_filter_low')));
    await tester.tap(find.byKey(const ValueKey('category_filter_건강')));
    await tester.tap(find.byKey(const ValueKey('apply_filter_button')));
    await tester.pumpAndSettle();
    expect(
      Get.find<TodoController>().todoSortOption.value,
      TodoSortOption.newest,
    );
    expect(find.text('완료 운동'), findsOneWidget);
    expect(find.text('내일 장보기'), findsNothing);
  });

  testWidgets('루틴 Todo에 배지를 표시하고 유형 필터로 구분한다', (tester) async {
    repository.values.add(
      Todo(
        id: 4,
        title: '아침 루틴',
        dueAt: DateTime.now(),
        routineId: 10,
        routineDate: DateUtils.dateOnly(DateTime.now()),
        createdAt: DateTime.now(),
      ),
    );
    await Get.find<TodoController>().loadTodos();
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo_routine_badge_4')), findsOneWidget);
    expect(find.text('테스트 할 일'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('regular_section_header')),
        matching: find.text('오늘 할 일'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('routine_section_header')),
        matching: find.text('오늘의 루틴'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('status_filter_all')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('regular_section_header')),
        matching: find.text('일반 할 일'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('routine_section_header')),
        matching: find.text('루틴 일정'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('advanced_filter_button')));
    await tester.pumpAndSettle();
    expect(find.text('루틴 일정'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('todo_type_routine')));
    await tester.tap(find.byKey(const ValueKey('apply_filter_button')));
    await tester.pumpAndSettle();

    expect(find.text('아침 루틴'), findsOneWidget);
    expect(find.text('테스트 할 일'), findsNothing);
    expect(
      Get.find<TodoController>().todoTypeFilter.value,
      TodoTypeFilter.routine,
    );
  });

  testWidgets('캘린더 검색 결과로 날짜를 이동하고 전용 필터를 함께 적용한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar_search_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('calendar_search_field')),
      '장보기',
    );
    await tester.pump();
    expect(find.text('검색 결과 1개'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calendar_search_result_3')));
    await tester.pumpAndSettle();
    expect(
      DateUtils.isSameDay(
        controller.selectedDay.value,
        repository.values.firstWhere((todo) => todo.id == 3).dueAt,
      ),
      isTrue,
    );

    await tester.enterText(
      find.byKey(const ValueKey('calendar_search_field')),
      '운동',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('calendar_filter_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar_status_completed')));
    await tester.tap(find.byKey(const ValueKey('apply_calendar_filters')));
    await tester.pumpAndSettle();

    expect(controller.calendarSearchQuery.value, '운동');
    expect(
      controller.calendarStatusFilter.value,
      CalendarStatusFilter.completed,
    );
    expect(
      find.byKey(const ValueKey('calendar_search_result_2')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('calendar_search_result_2')));
    await tester.pumpAndSettle();
    expect(find.text('완료 운동'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('calendar_filter_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar_status_incomplete')));
    await tester.tap(find.byKey(const ValueKey('apply_calendar_filters')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('calendar_page_list')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(find.text('현재 조건에 맞는 일정이 없어요.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reset_calendar_conditions')));
    await tester.pumpAndSettle();
    expect(controller.calendarSearchQuery.value, isEmpty);
    expect(controller.hasCalendarFilter, isFalse);
  });

  testWidgets('캘린더 아이콘과 범례가 일정 상태를 구분한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();
    final today = DateTime.now();
    final dateKey = '${today.year}_${today.month}_${today.day}';

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('calendar_marker_legend')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('calendar_incomplete_marker_$dateKey')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('calendar_completed_marker_$dateKey')),
      findsNothing,
    );
    expect(find.text('총 2개 · 완료 1개 · 남음 1개'), findsOneWidget);

    final incompleteTodo = controller.todos.firstWhere((todo) => todo.id == 1);
    controller.currentTime.value = incompleteTodo.dueAt.add(
      const Duration(minutes: 1),
    );
    await tester.pump();

    expect(
      find.byKey(ValueKey('calendar_overdue_marker_$dateKey')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('calendar_incomplete_marker_$dateKey')),
      findsNothing,
    );

    await controller.toggle(incompleteTodo);
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('calendar_completed_marker_$dateKey')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('calendar_incomplete_marker_$dateKey')),
      findsNothing,
    );
    expect(find.text('총 2개 · 완료 2개 · 남음 0개'), findsOneWidget);
  });

  testWidgets('입력값을 검증하고 집중 시간을 포함해 저장한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo_date_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('todo_time_button')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('estimated_minutes_field')),
      findsOneWidget,
    );
    expect(find.text('없음'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('todo_date_button')));
    await tester.pumpAndSettle();
    expect(find.text('날짜 설정'), findsOneWidget);
    final tomorrowShortcut = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('todo_date_shortcut_tomorrow')),
    );
    expect((tomorrowShortcut.label as Text).style?.color, Colors.black);
    await tester.tap(find.byKey(const ValueKey('todo_date_shortcut_tomorrow')));
    await tester.tap(find.byKey(const ValueKey('confirm_todo_date_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('todo_time_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('todo_analog_time_dial')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('toggle_todo_time_input_mode')),
      findsOneWidget,
    );
    final quickTime = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('todo_quick_time_14')),
    );
    expect((quickTime.label as Text).style?.color, Colors.black);
    await tester.ensureVisible(
      find.byKey(const ValueKey('todo_quick_time_14')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('todo_quick_time_14')));
    await tester.tap(find.byKey(const ValueKey('confirm_todo_time_button')));
    await tester.pumpAndSettle();
    expect(find.text('14:00'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '   ',
    );
    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pump();
    expect(find.text('공백이 아닌 제목을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      List.filled(61, '가').join(),
    );
    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pump();
    expect(find.text('제목은 60자 이하로 입력해 주세요.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '  새   할 일  ',
    );
    await tester.tap(find.byKey(const ValueKey('todo_time_button')));
    await tester.pumpAndSettle();
    expect(find.text('시간 설정'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('todo_time_none_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('todo_time_none_button')));
    await tester.pumpAndSettle();
    expect(find.text('시간 없음'), findsOneWidget);
    final formScroll = find
        .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('estimated_minutes_field')),
      180,
      scrollable: formScroll,
    );
    await tester.drag(formScroll, const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('estimated_minutes_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1시간').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pumpAndSettle();

    final saved = Get.find<TodoController>().todos.firstWhere(
      (todo) => todo.title == '새 할 일',
    );
    expect(saved.estimatedMinutes, 60);
    expect(saved.hasTime, isFalse);
    expect(saved.priority, 1);
    expect(saved.category, '없음');
    expect(saved.categoryId, isNull);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('지난 날짜에서 새 할 일을 열어도 미래 일정으로 저장한다', (tester) async {
    final controller = Get.find<TodoController>();
    controller.selectedDay.value = DateTime.now().subtract(
      const Duration(days: 1),
    );
    controller.selectedTab.value = 1;
    final openedAt = DateTime.now();

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '미래 일정 검증',
    );
    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pumpAndSettle();

    final saved = controller.todos.firstWhere(
      (todo) => todo.title == '미래 일정 검증',
    );
    expect(saved.dueAt.isAfter(openedAt), isTrue);
    expect(saved.estimatedMinutes, 0);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('새 할 일 화면에서 반복을 선택하면 루틴으로 저장한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '평일 업무 정리',
    );
    final formList = find.descendant(
      of: find.byType(Form),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('repeat_setting_button')),
      250,
      scrollable: formList.first,
    );
    expect(find.text('사용 안 함'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('repeat_setting_button')),
    );
    await tester.drag(formList.first, const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('repeat_setting_button')).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('repeat_option_custom')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('repeat_option_custom')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('todo_repeat_weekday_1')),
      180,
      scrollable: formList.first,
    );
    final mondayChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('todo_repeat_weekday_1')),
    );
    expect((mondayChip.label as Text).style?.color, Colors.black);
    expect(mondayChip.selected, isFalse);
    for (var weekday = 2; weekday <= 7; weekday++) {
      expect(
        tester
            .widget<FilterChip>(
              find.byKey(ValueKey('todo_repeat_weekday_$weekday')),
            )
            .selected,
        isFalse,
      );
    }

    await tester.tap(find.byKey(const ValueKey('repeat_setting_button')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('repeat_option_weekdays')));
    await tester.pumpAndSettle();
    expect(find.text('평일'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();
    expect(controller.routines.single.title, '평일 업무 정리');
    expect(controller.routines.single.repeatDays, {1, 2, 3, 4, 5});
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('작성 중 뒤로 가면 폐기 여부를 확인한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add_todo_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '저장 전 할 일',
    );
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('작성 내용을 버릴까요?'), findsOneWidget);
    await tester.tap(find.text('계속 작성'));
    await tester.pumpAndSettle();
    expect(find.text('새 할 일'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('discard_changes_button')));
    await tester.pumpAndSettle();
    expect(find.text('새 할 일'), findsNothing);
    expect(find.text('목록'), findsWidgets);
  });

  testWidgets('삭제한 할 일을 휴지통에서 복구하고 영구 삭제한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();

    await controller.moveToTrash(1);
    await tester.pump();
    expect(find.text('테스트 할 일'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('trash_button')));
    await tester.pumpAndSettle();
    expect(find.text('테스트 할 일'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('restore_todo_1')));
    await tester.pumpAndSettle();
    expect(find.text('휴지통이 비어 있어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('테스트 할 일'), findsOneWidget);

    await controller.moveToTrash(1);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('trash_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('permanent_delete_todo_1')));
    await tester.pumpAndSettle();
    expect(find.text('영구 삭제할까요?'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('confirm_permanent_delete_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('휴지통이 비어 있어요'), findsOneWidget);
    expect(controller.deletedTodos, isEmpty);
  });

  testWidgets('삭제 안내는 3초 안에 사라지고 휴지통 전체 작업을 지원한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();

    await tester.drag(
      find.byKey(const ValueKey('todo_card_1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slide_delete_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm_delete_button')));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    await controller.moveToTrash(2);
    await tester.tap(find.byKey(const ValueKey('trash_button')));
    await tester.pumpAndSettle();
    expect(controller.deletedTodos, hasLength(2));

    await tester.tap(find.byKey(const ValueKey('restore_all_todos')));
    await tester.pumpAndSettle();
    expect(find.text('모두 복구할까요?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm_restore_all_button')));
    await tester.pumpAndSettle();
    expect(controller.deletedTodos, isEmpty);

    await controller.moveToTrash(1);
    await controller.moveToTrash(2);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('delete_all_todos')));
    await tester.pumpAndSettle();
    expect(find.text('휴지통을 비울까요?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm_delete_all_button')));
    await tester.pumpAndSettle();
    expect(controller.deletedTodos, isEmpty);
  });

  testWidgets('오늘의 미완료 Todo에 남은 예상 집중 시간을 적용한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();

    expect(controller.focusEligibleTodos.map((todo) => todo.id), [1]);
    await tester.tap(find.byIcon(Icons.timer_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.music_note_rounded), findsNothing);
    expect(find.byIcon(Icons.more_vert_rounded), findsNothing);

    await tester.tap(find.byKey(const ValueKey('focus_todo_selector')));
    await tester.pumpAndSettle();
    expect(find.text('완료 운동'), findsNothing);
    expect(find.text('내일 장보기'), findsNothing);
    final focusOption = find.byKey(const ValueKey('focus_todo_option_1'));
    expect(focusOption, findsOneWidget);
    expect(tester.getSize(focusOption).width, lessThan(360));
    expect(find.text('남음 30분'), findsOneWidget);
    await tester.tap(find.text('테스트 할 일').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('custom_focus_duration_button')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('focus_duration_selector')), findsNothing);
    expect(find.byKey(const ValueKey('remaining_focus_time')), findsOneWidget);
    expect(find.text('30:00'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('focus_toggle_button')),
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('focus_page_list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('focus_toggle_button')));
    await tester.pump();
    expect(controller.activeWorkSession.value?.plannedSeconds, 1800);
    await controller.completeFocus();
    await tester.pumpAndSettle();
  });

  testWidgets('예상 집중 시간을 달성한 Todo는 선택에서 제외하고 계획에는 유지한다', (tester) async {
    final now = DateTime.now();
    repository.sessionValues.add(
      WorkSession(
        id: 1,
        todoId: 1,
        plannedSeconds: 1800,
        elapsedSeconds: 1800,
        startedAt: now.subtract(const Duration(minutes: 30)),
        status: WorkSessionStatus.completed,
        completedAt: now,
      ),
    );
    final controller = Get.find<TodoController>();
    await controller.loadTodos();

    expect(controller.focusEligibleTodos, isEmpty);
    expect(controller.selectedFocusTodoId.value, isNull);
    expect(
      controller.todos.firstWhere((todo) => todo.id == 1).isCompleted,
      isFalse,
    );

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.timer_outlined).first);
    await tester.pumpAndSettle();

    final selector = tester.widget<PopupMenuButton<int>>(
      find.byKey(const ValueKey('focus_todo_selector')),
    );
    expect(selector.enabled, isFalse);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('focus_estimate_reached_1')),
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('focus_page_list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      find.byKey(const ValueKey('focus_estimate_reached_1')),
      findsOneWidget,
    );
    expect(find.text('목표 시간 달성'), findsOneWidget);
  });

  testWidgets('집중 세션 상태와 실제 집중 시간을 SQLite 흐름으로 반영한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();
    final controller = Get.find<TodoController>();

    await controller.startFocus(todoId: 1, plannedSeconds: 60);
    expect(controller.activeWorkSession.value?.todoId, 1);
    expect(
      controller.activeWorkSession.value?.status,
      WorkSessionStatus.running,
    );
    expect(controller.activeWorkSession.value?.endsAt, isNotNull);

    await controller.pauseFocus();
    expect(
      controller.activeWorkSession.value?.status,
      WorkSessionStatus.paused,
    );
    expect(controller.activeWorkSession.value?.endsAt, isNull);
    expect(controller.activeWorkSession.value?.pausedAt, isNotNull);

    await controller.resumeFocus();
    expect(
      controller.activeWorkSession.value?.status,
      WorkSessionStatus.running,
    );
    expect(controller.activeWorkSession.value?.endsAt, isNotNull);
    expect(controller.activeWorkSession.value?.pausedAt, isNull);
    await controller.completeFocus();
    expect(controller.activeWorkSession.value, isNull);
    expect(controller.workSessions.first.completedAt, isNotNull);

    final now = DateTime.now();
    await repository.insertWorkSession(
      WorkSession(
        todoId: 1,
        plannedSeconds: 600,
        elapsedSeconds: 600,
        startedAt: now.subtract(const Duration(minutes: 10)),
        status: WorkSessionStatus.completed,
        completedAt: now,
      ),
    );
    await repository.insertWorkSession(
      WorkSession(
        todoId: 1,
        plannedSeconds: 120,
        elapsedSeconds: 0,
        startedAt: now.subtract(const Duration(minutes: 3)),
        status: WorkSessionStatus.running,
        endsAt: now.subtract(const Duration(seconds: 1)),
      ),
    );
    await repository.insertWorkSession(
      WorkSession(
        todoId: 1,
        plannedSeconds: 300,
        elapsedSeconds: 300,
        startedAt: now.subtract(const Duration(days: 7, minutes: 5)),
        status: WorkSessionStatus.completed,
        completedAt: now.subtract(const Duration(days: 7)),
      ),
    );
    await controller.loadTodos();

    expect(controller.activeWorkSession.value, isNull);
    expect(
      controller.workSessions
          .firstWhere((session) => session.plannedSeconds == 120)
          .elapsedSeconds,
      120,
    );
    expect(controller.todayFocusSeconds, inInclusiveRange(720, 725));
    expect(
      controller.weeklyFocusSeconds.fold<int>(0, (sum, value) => sum + value),
      inInclusiveRange(720, 725),
    );
    expect(
      controller
          .weeklyFocusSecondsFor(-1)
          .fold<int>(0, (sum, value) => sum + value),
      300,
    );
    expect(
      controller
          .weeklyCreatedCountsFor(0)
          .fold<int>(0, (sum, value) => sum + value),
      3,
    );
    expect(controller.categoryCompletionStats['건강']?.completed, 1);
    expect(controller.priorityCompletionStats[0]?.completed, 1);

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('weekly_focus_total')),
      250,
    );
    final focusTotal = tester.widget<Text>(
      find.byKey(const ValueKey('weekly_focus_total')),
    );
    expect(focusTotal.data, '12분');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('weekly_comparison_panel')),
      300,
    );
    expect(find.text('이번 주와 지난주 비교'), findsOneWidget);
    expect(find.text('데이터 내보내기'), findsNothing);
  });

  testWidgets('Todo 예상 대비 누적 집중을 표시하고 완료 여부를 선택한다', (tester) async {
    final now = DateTime.now();
    await repository.insertWorkSession(
      WorkSession(
        todoId: 1,
        plannedSeconds: 600,
        elapsedSeconds: 600,
        startedAt: now.subtract(const Duration(minutes: 10)),
        status: WorkSessionStatus.completed,
        completedAt: now,
      ),
    );
    final controller = Get.find<TodoController>();
    await controller.loadTodos();
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.timer_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('todo_focus_progress')), findsOneWidget);
    expect(controller.focusSecondsForTodo(1), 600);
    expect(
      controller.remainingEstimatedSecondsFor(controller.selectedFocusTodo!),
      1200,
    );
    expect(find.byKey(const ValueKey('remaining_focus_time')), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('custom_focus_duration_button')),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('focus_toggle_button')),
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('focus_page_list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('focus_toggle_button')));
    await tester.pump();
    expect(controller.activeWorkSession.value?.plannedSeconds, 1200);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('focus_complete_button')),
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('focus_page_list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('focus_complete_button')));
    await tester.pumpAndSettle();
    expect(find.text('집중을 완료했어요'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('focus_completion_dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('focus_completion_actual_time')),
      findsOneWidget,
    );
    expect(
      tester.widget(find.byKey(const ValueKey('focus_complete_again'))),
      isA<FilledButton>(),
    );
    expect(
      tester.widget(find.byKey(const ValueKey('focus_complete_todo'))),
      isA<OutlinedButton>(),
    );
    expect(find.text('닫기'), findsOneWidget);
    expect(find.text('할 일 완료'), findsOneWidget);
    expect(
      controller.todos.firstWhere((todo) => todo.id == 1).isCompleted,
      isFalse,
    );
    await tester.tap(find.byKey(const ValueKey('focus_complete_todo')));
    await tester.pumpAndSettle();
    expect(
      controller.todos.firstWhere((todo) => todo.id == 1).isCompleted,
      isTrue,
    );
    expect(
      controller.todos.firstWhere((todo) => todo.id == 1).completedAt,
      isNotNull,
    );
  });

  testWidgets('루틴을 등록하면 오늘 Todo를 중복 없이 생성하고 비활성화한다', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.repeat_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('등록된 루틴이 없어요'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add_routine_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('todo_title_field')),
      '매일 보고서 확인',
    );
    final routineFormList = find.descendant(
      of: find.byType(Form),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('repeat_setting_button')),
      250,
      scrollable: routineFormList.first,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('repeat_setting_button')),
    );
    await tester.drag(routineFormList.first, const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(find.text('매일'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('save_todo_button')));
    await tester.pumpAndSettle();

    final controller = Get.find<TodoController>();
    expect(controller.routines, hasLength(1));
    expect(
      controller.todos.where((todo) => todo.title == '매일 보고서 확인'),
      hasLength(1),
    );
    expect(find.text('생성된 일정 1개 · 완료 0개'), findsOneWidget);
    expect(find.byKey(const ValueKey('routine_status_1')), findsOneWidget);
    expect(find.text('자동 생성'), findsOneWidget);
    final routineSwitch = tester.widget<Switch>(
      find.byKey(const ValueKey('routine_toggle_1')),
    );
    expect(routineSwitch.value, isTrue);
    expect(routineSwitch.activeTrackColor, AppColors.primary);
    expect(
      routineSwitch.thumbIcon?.resolve({WidgetState.selected})?.icon,
      Icons.check_rounded,
    );
    await controller.loadTodos();
    expect(
      controller.todos.where((todo) => todo.title == '매일 보고서 확인'),
      hasLength(1),
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await tester.pumpAndSettle();
    final initialTodoListScroll = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('매일 보고서 확인'),
      180,
      scrollable: initialTodoListScroll,
    );
    await tester.drag(initialTodoListScroll, const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.tap(find.text('매일 보고서 확인'));
    await tester.pumpAndSettle();
    expect(find.text('무엇을 수정할까요?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('edit_future_routine')));
    await tester.pumpAndSettle();
    expect(find.text('루틴 수정'), findsOneWidget);
    final editFormScroll = find
        .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('repeat_setting_button')),
      250,
      scrollable: editFormScroll,
    );
    await tester.drag(editFormScroll, const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(find.text('매일'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('close_task_form_button')));
    await tester.pumpAndSettle();

    final todoListScroll = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('todo_card_4')),
      180,
      scrollable: todoListScroll,
    );
    await tester.drag(todoListScroll, const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('todo_card_4')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slide_delete_4')));
    await tester.pumpAndSettle();
    expect(find.text('이 반복 일정을 어떻게 처리할까요?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('stop_todo_routine')));
    await tester.pumpAndSettle();
    expect(controller.routines.single.isActive, isFalse);
    expect(find.text('매일 보고서 확인'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.repeat_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('일시 중지'), findsWidgets);
    expect(find.byKey(const ValueKey('delete_routine_1')), findsNothing);
    await tester.drag(
      find.byKey(const ValueKey('routine_card_1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('slide_delete_routine_1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('slide_delete_routine_1')));
    await tester.pumpAndSettle();
    expect(find.text('루틴을 삭제할까요?'), findsOneWidget);
    expect(find.textContaining('삭제한 루틴은 다시 켤 수 없습니다.'), findsOneWidget);
    expect(find.text('루틴만 삭제'), findsOneWidget);
    expect(find.text('미완료 일정은 휴지통으로'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm_delete_routine')));
    await tester.pumpAndSettle();
    expect(controller.routines, isEmpty);
    expect(find.text('등록된 루틴이 없어요'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await tester.pumpAndSettle();
    expect(find.text('종료된 루틴'), findsOneWidget);
  });
}
