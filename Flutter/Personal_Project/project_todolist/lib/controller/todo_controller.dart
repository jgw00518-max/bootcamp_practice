import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_todolist/data/todo_database.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/model/todo_category.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/work_session.dart';

/// 목록에서 선택할 수 있는 Todo 상태 조건입니다.
enum TodoStatusFilter { all, today, completed, incomplete }

/// 목록에서 필터링된 Todo를 표시할 순서입니다.
enum TodoSortOption { dueSoonest, newest, title, priority }

/// 목록에서 일반 Todo와 루틴에서 생성된 Todo를 구분하는 조건입니다.
enum TodoTypeFilter { all, normal, routine }

/// 캘린더에서 날짜와 무관하게 적용할 완료 상태 조건입니다.
enum CalendarStatusFilter { all, completed, incomplete }

/// 캘린더에서 일반 Todo와 루틴 Todo를 구분합니다.
enum CalendarTodoTypeFilter { all, normal, routine }

/// SQLite 데이터를 불러와 모든 화면에 반응형 상태로 제공합니다.
class TodoController extends GetxController with WidgetsBindingObserver {
  TodoController(this._database);

  final TodoRepository _database;
  final todos = <Todo>[].obs;
  final categories = <TodoCategory>[].obs;
  final analyticsTodos = <Todo>[].obs;
  final deletedTodos = <DeletedTodo>[].obs;
  final workSessions = <WorkSession>[].obs;
  final routines = <Routine>[].obs;
  final activeWorkSession = Rxn<WorkSession>();
  final isStartingFocus = false.obs;
  final selectedFocusTodoId = RxnInt();
  final selectedTab = 0.obs;
  final selectedDay = DateTime.now().obs;
  final currentTime = DateTime.now().obs;
  final isLoading = true.obs;
  final loadError = RxnString();
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();
  final statusFilter = TodoStatusFilter.today.obs;
  final priorityFilter = RxnInt();
  final categoryFilter = RxnString();
  final todoTypeFilter = TodoTypeFilter.all.obs;
  final todoSortOption = TodoSortOption.dueSoonest.obs;
  final calendarSearchQuery = ''.obs;
  final calendarSearchTextController = TextEditingController();
  final isCalendarSearchOpen = false.obs;
  final calendarStatusFilter = CalendarStatusFilter.all.obs;
  final calendarPriorityFilter = RxnInt();
  final calendarCategoryFilter = RxnString();
  final calendarTodoTypeFilter = CalendarTodoTypeFilter.all.obs;
  Future<bool>? _loadFuture;
  bool _reloadRequested = false;
  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _scheduleClockTick();
    loadTodos();
  }

  /// 앱 복귀 시 날짜 변경과 만료된 집중 세션을 함께 다시 계산합니다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      currentTime.value = DateTime.now();
      _scheduleClockTick();
      loadTodos();
    }
  }

  /// 분이 바뀌는 시점에 현재 시각을 갱신해 기한 초과 UI를 자동 재계산합니다.
  void _scheduleClockTick() {
    _clockTimer?.cancel();
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));
    _clockTimer = Timer(nextMinute.difference(now), () {
      currentTime.value = DateTime.now();
      _scheduleClockTick();
    });
  }

  /// 동시 조회는 합치고 실행 중 들어온 갱신 요청은 마지막 한 번만 추가 실행합니다.
  Future<bool> loadTodos() {
    _reloadRequested = true;
    return _loadFuture ??= _drainLoadRequests().whenComplete(() {
      _loadFuture = null;
    });
  }

  Future<bool> _drainLoadRequests() async {
    isLoading.value = true;
    try {
      var succeeded = true;
      do {
        _reloadRequested = false;
        succeeded = await _loadTodosOnce();
      } while (_reloadRequested);
      return succeeded;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _loadTodosOnce() async {
    try {
      if (kDebugMode) {
        await _database.seedExamplesIfNeeded(DateTime.now());
      }
      await _database.syncRoutineTodos(DateTime.now());
      await _database.normalizeActiveWorkSessions();
      final stored = await _database.readTodos();
      final storedCategories = await _database.readCategories();
      final deleted = await _database.readDeletedTodos();
      final storedAnalytics = await _database.readAnalyticsTodos();
      var sessions = await _database.readWorkSessions();
      final storedRoutines = await _database.readRoutines();
      todos.assignAll(stored);
      categories.assignAll(storedCategories);
      deletedTodos.assignAll(deleted);
      analyticsTodos.assignAll(storedAnalytics);
      var active = _findActiveSession(sessions);
      if (active?.isRunning == true &&
          active!.remainingAt(DateTime.now()) == 0) {
        await _completeSession(active, DateTime.now());
        sessions = await _database.readWorkSessions();
        active = _findActiveSession(sessions);
      }
      workSessions.assignAll(sessions);
      routines.assignAll(storedRoutines);
      activeWorkSession.value = active;
      if (active != null) {
        selectedFocusTodoId.value = active.todoId;
      } else {
        final selectedIsEligible = stored.any(
          (todo) =>
              todo.id == selectedFocusTodoId.value &&
              _isFocusEligible(todo, currentTime.value),
        );
        if (!selectedIsEligible) {
          selectedFocusTodoId.value = _firstFocusTodoId(stored);
        }
      }
      loadError.value = null;
      return true;
    } catch (_) {
      loadError.value = '데이터를 불러오지 못했습니다.';
      return false;
    }
  }

  /// DB 쓰기와 화면 데이터 갱신을 묶고 실패 시 성공 흐름을 중단합니다.
  Future<bool> _runWrite(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      Get.snackbar(
        '작업을 완료하지 못했습니다',
        '데이터를 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    final reloaded = await loadTodos();
    if (!reloaded) {
      Get.snackbar(
        '저장은 완료했어요',
        '화면을 갱신하지 못했습니다. 다시 시도해 주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return reloaded;
  }

  Future<bool> addTodo(Todo todo) => _runWrite(() async {
    await _database.insert(todo);
  });

  /// `없음`을 제외한 현재 카테고리 이름을 입력 화면과 필터에 제공합니다.
  List<String> get categoryNames =>
      categories.map((item) => item.name).toList();

  /// 카테고리 이름은 공백·중복·길이를 검증한 뒤 저장합니다.
  String? validateCategoryName(String value, {int? excludingId}) {
    final name = value.trim();
    if (name.isEmpty) return '카테고리 이름을 입력해 주세요.';
    if (name == '없음') return '없음은 기본 항목이라 사용할 수 없습니다.';
    if (name.length > 20) return '카테고리 이름은 20자 이하로 입력해 주세요.';
    final duplicated = categories.any(
      (item) =>
          item.id != excludingId &&
          item.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicated) return '이미 사용 중인 카테고리 이름입니다.';
    return null;
  }

  Future<bool> addCategory(String name) => _runWrite(() async {
    await _database.insertCategory(name.trim());
  });

  Future<bool> updateCategory(TodoCategory category, String name) async {
    final oldName = category.name;
    final normalized = name.trim();
    final succeeded = await _runWrite(() async {
      await _database.updateCategory(category.id, normalized);
    });
    if (succeeded) {
      if (categoryFilter.value == oldName) categoryFilter.value = normalized;
      if (calendarCategoryFilter.value == oldName) {
        calendarCategoryFilter.value = normalized;
      }
    }
    return succeeded;
  }

  Future<bool> deleteCategory(TodoCategory category) async {
    final succeeded = await _runWrite(() async {
      await _database.deleteCategory(category.id);
    });
    if (succeeded) {
      if (categoryFilter.value == category.name) categoryFilter.value = null;
      if (calendarCategoryFilter.value == category.name) {
        calendarCategoryFilter.value = null;
      }
    }
    return succeeded;
  }

  /// 루틴을 저장하고 오늘 적용되는 Todo를 즉시 생성합니다.
  Future<bool> addRoutine(Routine routine) => _runWrite(() async {
    await _database.insertRoutine(routine);
  });

  /// 루틴 변경은 앞으로 생성될 Todo에 적용하고 기존 Todo는 유지합니다.
  Future<bool> updateRoutine(Routine routine) => _runWrite(() async {
    await _database.updateRoutine(routine);
  });

  Future<bool> toggleRoutine(Routine routine) => _runWrite(() async {
    await _database.updateRoutine(
      routine.copyWith(isActive: !routine.isActive),
    );
  });

  Future<bool> deleteRoutine(
    int id, {
    bool moveIncompleteTodosToTrash = false,
  }) => _runWrite(() async {
    await _database.deleteRoutine(
      id,
      moveIncompleteTodosToTrash: moveIncompleteTodosToTrash,
    );
  });

  /// 수정된 할 일을 저장하고 공용 목록을 다시 불러옵니다.
  Future<bool> updateTodo(Todo todo) => _runWrite(() async {
    await _database.update(todo);
  });

  /// 할 일을 휴지통으로 이동하고 모든 화면의 공용 상태를 갱신합니다.
  Future<bool> moveToTrash(int id) => _runWrite(() async {
    await _database.moveToTrash(id);
  });

  /// 휴지통 Todo를 원래 ID와 일정으로 복구합니다.
  Future<bool> restoreTodo(int id) => _runWrite(() async {
    await _database.restoreTodo(id);
  });

  /// 휴지통의 모든 Todo를 복구하고 관련 화면 상태를 한 번만 갱신합니다.
  Future<bool> restoreAllTodos() => _runWrite(_database.restoreAllTodos);

  /// 휴지통 Todo를 영구 삭제합니다.
  Future<bool> permanentlyDeleteTodo(int id) => _runWrite(() async {
    await _database.permanentlyDeleteTodo(id);
  });

  /// 휴지통의 모든 Todo를 영구 삭제하고 관련 화면 상태를 갱신합니다.
  Future<bool> permanentlyDeleteAllTodos() =>
      _runWrite(_database.permanentlyDeleteAllTodos);

  Future<bool> toggle(Todo todo) async {
    if (todo.id == null) return false;
    return _runWrite(() async {
      await _database.setTodoCompletion(
        todo.id!,
        isCompleted: todo.completedAt == null,
      );
    });
  }

  List<Todo> get todayTodos {
    final now = currentTime.value;
    return todos.where((todo) => _sameDay(todo.dueAt, now)).toList();
  }

  /// 완료되지 않은 Todo의 날짜와 시간이 현재 시각을 지났는지 판단합니다.
  bool isTodoOverdue(Todo todo) =>
      !todo.isCompleted && currentTime.value.isAfter(todo.deadlineAt);

  /// 오늘의 미완료 Todo 중 예상 집중 시간이 남은 항목만 제공합니다.
  List<Todo> get focusEligibleTodos => todayTodos
      .where((todo) => _isFocusEligible(todo, currentTime.value))
      .toList();

  bool _isFocusEligible(Todo todo, DateTime now) =>
      todo.id != null &&
      !todo.isCompleted &&
      _sameDay(todo.dueAt, now) &&
      remainingEstimatedSecondsFor(todo) > 0;

  Todo? get selectedFocusTodo {
    for (final todo in focusEligibleTodos) {
      if (todo.id == selectedFocusTodoId.value) return todo;
    }
    return null;
  }

  /// Todo에 연결된 완료 집중 세션의 실제 시간을 합산합니다.
  int focusSecondsForTodo(int todoId) => workSessions
      .where((session) => session.todoId == todoId && session.isCompleted)
      .fold(0, (sum, session) => sum + session.elapsedSeconds);

  int remainingEstimatedSecondsFor(Todo todo) {
    final remaining =
        todo.estimatedMinutes * 60 - focusSecondsForTodo(todo.id!);
    return remaining > 0 ? remaining : 0;
  }

  List<Todo> todosFor(DateTime day) =>
      todos.where((todo) => _sameDay(todo.dueAt, day)).toList();

  /// 검색어와 캘린더 전용 필터를 모두 적용한 전체 일정입니다.
  List<Todo> get calendarFilteredTodos {
    final query = calendarSearchQuery.value.trim().toLowerCase();
    final result = todos.where((todo) {
      final matchesQuery =
          query.isEmpty ||
          todo.title.toLowerCase().contains(query) ||
          todo.memo.toLowerCase().contains(query) ||
          todo.category.toLowerCase().contains(query);
      final matchesStatus = switch (calendarStatusFilter.value) {
        CalendarStatusFilter.all => true,
        CalendarStatusFilter.completed => todo.isCompleted,
        CalendarStatusFilter.incomplete => !todo.isCompleted,
      };
      final matchesPriority =
          calendarPriorityFilter.value == null ||
          todo.priority == calendarPriorityFilter.value;
      final matchesCategory =
          calendarCategoryFilter.value == null ||
          todo.category == calendarCategoryFilter.value;
      final matchesType = switch (calendarTodoTypeFilter.value) {
        CalendarTodoTypeFilter.all => true,
        CalendarTodoTypeFilter.normal => todo.routineId == null,
        CalendarTodoTypeFilter.routine => todo.routineId != null,
      };
      return matchesQuery &&
          matchesStatus &&
          matchesPriority &&
          matchesCategory &&
          matchesType;
    }).toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return result;
  }

  List<Todo> calendarTodosFor(DateTime day) =>
      calendarFilteredTodos.where((todo) => _sameDay(todo.dueAt, day)).toList();

  /// 미래 날짜에 적용되는 루틴을 실제 Todo 저장 없이 캘린더 예정 항목으로 계산합니다.
  List<Routine> calendarRoutinePreviewsFor(DateTime day) {
    final targetDay = DateTime(day.year, day.month, day.day);
    final today = DateTime(
      currentTime.value.year,
      currentTime.value.month,
      currentTime.value.day,
    );
    if (!targetDay.isAfter(today)) return const <Routine>[];

    final existingRoutineIds = todos
        .where((todo) => _sameDay(todo.dueAt, targetDay))
        .map((todo) => todo.routineId)
        .whereType<int>()
        .toSet();
    final deletedRoutineIds = deletedTodos
        .where(
          (deleted) =>
              deleted.todo.routineDate != null &&
              _sameDay(deleted.todo.routineDate!, targetDay),
        )
        .map((deleted) => deleted.todo.routineId)
        .whereType<int>()
        .toSet();
    final query = calendarSearchQuery.value.trim().toLowerCase();

    final previews =
        routines.where((routine) {
          final matchesQuery =
              query.isEmpty ||
              routine.title.toLowerCase().contains(query) ||
              routine.memo.toLowerCase().contains(query) ||
              routine.category.toLowerCase().contains(query);
          final matchesStatus =
              calendarStatusFilter.value != CalendarStatusFilter.completed;
          final matchesPriority =
              calendarPriorityFilter.value == null ||
              routine.priority == calendarPriorityFilter.value;
          final matchesCategory =
              calendarCategoryFilter.value == null ||
              routine.category == calendarCategoryFilter.value;
          final matchesType =
              calendarTodoTypeFilter.value != CalendarTodoTypeFilter.normal;
          return routine.id != null &&
              routine.appliesTo(targetDay) &&
              !existingRoutineIds.contains(routine.id) &&
              !deletedRoutineIds.contains(routine.id) &&
              matchesQuery &&
              matchesStatus &&
              matchesPriority &&
              matchesCategory &&
              matchesType;
        }).toList()..sort((a, b) {
          final hour = a.scheduledHour.compareTo(b.scheduledHour);
          return hour != 0
              ? hour
              : a.scheduledMinute.compareTo(b.scheduledMinute);
        });
    return previews;
  }

  bool get hasCalendarFilter =>
      calendarStatusFilter.value != CalendarStatusFilter.all ||
      calendarPriorityFilter.value != null ||
      calendarCategoryFilter.value != null ||
      calendarTodoTypeFilter.value != CalendarTodoTypeFilter.all;

  int get calendarFilterCount => [
    calendarStatusFilter.value != CalendarStatusFilter.all,
    calendarPriorityFilter.value != null,
    calendarCategoryFilter.value != null,
    calendarTodoTypeFilter.value != CalendarTodoTypeFilter.all,
  ].where((active) => active).length;

  void clearCalendarSearch() {
    calendarSearchTextController.clear();
    calendarSearchQuery.value = '';
  }

  void clearCalendarFilters() {
    calendarStatusFilter.value = CalendarStatusFilter.all;
    calendarPriorityFilter.value = null;
    calendarCategoryFilter.value = null;
    calendarTodoTypeFilter.value = CalendarTodoTypeFilter.all;
  }

  void clearCalendarConditions() {
    clearCalendarSearch();
    clearCalendarFilters();
  }

  /// 검색어와 상태·우선순위·카테고리 조건을 모두 적용한 결과입니다.
  List<Todo> get filteredTodos {
    final query = searchQuery.value.trim().toLowerCase();
    final result = todos.where((todo) {
      final matchesQuery =
          query.isEmpty ||
          todo.title.toLowerCase().contains(query) ||
          todo.memo.toLowerCase().contains(query);
      final matchesStatus = switch (statusFilter.value) {
        TodoStatusFilter.all => true,
        TodoStatusFilter.today => _sameDay(todo.dueAt, currentTime.value),
        TodoStatusFilter.completed => todo.isCompleted,
        TodoStatusFilter.incomplete => !todo.isCompleted,
      };
      final matchesPriority =
          priorityFilter.value == null || todo.priority == priorityFilter.value;
      final matchesCategory =
          categoryFilter.value == null || todo.category == categoryFilter.value;
      final matchesType = switch (todoTypeFilter.value) {
        TodoTypeFilter.all => true,
        TodoTypeFilter.normal => todo.routineId == null,
        TodoTypeFilter.routine => todo.routineId != null,
      };
      return matchesQuery &&
          matchesStatus &&
          matchesPriority &&
          matchesCategory &&
          matchesType;
    }).toList();
    result.sort(_compareFilteredTodos);
    return result;
  }

  int _compareFilteredTodos(Todo a, Todo b) {
    final compared = switch (todoSortOption.value) {
      TodoSortOption.dueSoonest => a.dueAt.compareTo(b.dueAt),
      TodoSortOption.newest => (b.createdAt ?? DateTime(1970)).compareTo(
        a.createdAt ?? DateTime(1970),
      ),
      TodoSortOption.title => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
      TodoSortOption.priority => b.priority.compareTo(a.priority),
    };
    if (compared != 0) return compared;
    final dueCompared = a.dueAt.compareTo(b.dueAt);
    if (dueCompared != 0) return dueCompared;
    return (a.id ?? 0).compareTo(b.id ?? 0);
  }

  /// 검색과 모든 필터를 초기 상태로 되돌립니다.
  void clearFilters() {
    searchTextController.clear();
    searchQuery.value = '';
    statusFilter.value = TodoStatusFilter.today;
    priorityFilter.value = null;
    categoryFilter.value = null;
    todoTypeFilter.value = TodoTypeFilter.all;
    todoSortOption.value = TodoSortOption.dueSoonest;
  }

  bool get hasDetailedFilter =>
      priorityFilter.value != null ||
      categoryFilter.value != null ||
      todoTypeFilter.value != TodoTypeFilter.all ||
      todoSortOption.value != TodoSortOption.dueSoonest;

  /// 선택한 Todo에 연결된 새 집중 세션을 시작합니다.
  Future<bool> startFocus({
    required int todoId,
    int plannedSeconds = 1500,
  }) async {
    if (isStartingFocus.value || activeWorkSession.value != null) return false;
    isStartingFocus.value = true;
    try {
      await _database.normalizeActiveWorkSessions();
      final sessions = await _database.readWorkSessions();
      if (_findActiveSession(sessions) != null) {
        workSessions.assignAll(sessions);
        activeWorkSession.value = _findActiveSession(sessions);
        return false;
      }
      final now = DateTime.now();
      await _database.insertWorkSession(
        WorkSession(
          todoId: todoId,
          plannedSeconds: plannedSeconds,
          elapsedSeconds: 0,
          startedAt: now,
          status: WorkSessionStatus.running,
          endsAt: now.add(Duration(seconds: plannedSeconds)),
        ),
      );
      selectedFocusTodoId.value = todoId;
      await loadTodos();
      return true;
    } catch (_) {
      Get.snackbar(
        '집중을 시작하지 못했습니다',
        '데이터를 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isStartingFocus.value = false;
    }
  }

  /// 실행 중 세션의 경과 시간을 확정하고 일시정지 상태로 저장합니다.
  Future<bool> pauseFocus() async {
    final session = activeWorkSession.value;
    if (session == null || !session.isRunning) return false;
    final paused = session.copyWith(
      elapsedSeconds: session.elapsedAt(DateTime.now()),
      status: WorkSessionStatus.paused,
      clearEndsAt: true,
      pausedAt: DateTime.now(),
    );
    return _runWrite(() => _database.updateWorkSession(paused));
  }

  /// 일시정지 세션을 남은 시간만큼의 새 종료 시각으로 재개합니다.
  Future<bool> resumeFocus() async {
    final session = activeWorkSession.value;
    if (session == null || !session.isPaused) return false;
    final remaining = session.plannedSeconds - session.elapsedSeconds;
    final resumed = session.copyWith(
      status: WorkSessionStatus.running,
      endsAt: DateTime.now().add(Duration(seconds: remaining)),
      clearPausedAt: true,
    );
    return _runWrite(() => _database.updateWorkSession(resumed));
  }

  /// 현재까지의 실제 집중 시간을 완료 세션으로 확정합니다.
  Future<bool> completeFocus() async {
    final session = activeWorkSession.value;
    if (session == null) return false;
    return _runWrite(() => _completeSession(session, DateTime.now()));
  }

  /// 앱 재개 시 종료 시각을 확인해 만료된 세션을 자동 완료합니다.
  Future<void> syncFocusSession() async {
    final session = activeWorkSession.value;
    if (session?.isRunning == true &&
        session!.remainingAt(DateTime.now()) == 0) {
      await completeFocus();
    }
  }

  Future<void> _completeSession(WorkSession session, DateTime now) async {
    final elapsed = session.isRunning
        ? session.elapsedAt(now)
        : session.elapsedSeconds;
    await _database.updateWorkSession(
      session.copyWith(
        elapsedSeconds: elapsed,
        status: WorkSessionStatus.completed,
        clearEndsAt: true,
        clearPausedAt: true,
        completedAt: now,
      ),
    );
  }

  WorkSession? _findActiveSession(List<WorkSession> sessions) {
    for (final session in sessions) {
      if (!session.isCompleted) return session;
    }
    return null;
  }

  int? _firstFocusTodoId(List<Todo> values) {
    for (final todo in values) {
      if (_isFocusEligible(todo, currentTime.value)) {
        return todo.id;
      }
    }
    return null;
  }

  /// 오늘 완료된 세션의 실제 집중 시간입니다.
  int get todayFocusSeconds => workSessions
      .where(
        (session) =>
            session.isCompleted &&
            session.completedAt != null &&
            _sameDay(session.completedAt!, DateTime.now()),
      )
      .fold(0, (sum, session) => sum + session.elapsedSeconds);

  /// 이번 주 월요일부터 일요일까지의 실제 집중 시간을 반환합니다.
  List<int> get weeklyFocusSeconds {
    final monday = _weekStart(0);
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return workSessions
          .where(
            (session) =>
                session.isCompleted &&
                session.completedAt != null &&
                _sameDay(session.completedAt!, day),
          )
          .fold(0, (sum, session) => sum + session.elapsedSeconds);
    });
  }

  List<int> weeklyFocusSecondsFor(int weekOffset) {
    final monday = _weekStart(weekOffset);
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return workSessions
          .where(
            (session) =>
                session.isCompleted &&
                session.completedAt != null &&
                _sameDay(session.completedAt!, day),
          )
          .fold(0, (sum, session) => sum + session.elapsedSeconds);
    });
  }

  List<int> weeklyCreatedCountsFor(int weekOffset) {
    final monday = _weekStart(weekOffset);
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return analyticsTodos
          .where(
            (todo) => todo.createdAt != null && _sameDay(todo.createdAt!, day),
          )
          .length;
    });
  }

  List<int> weeklyCompletedCountsFor(int weekOffset) {
    final monday = _weekStart(weekOffset);
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return analyticsTodos
          .where(
            (todo) =>
                todo.completedAt != null && _sameDay(todo.completedAt!, day),
          )
          .length;
    });
  }

  Map<String, ({int completed, int total})> get categoryCompletionStats {
    final categories = {...analyticsTodos.map((todo) => todo.category)}.toList()
      ..sort();
    return {
      for (final category in categories)
        category: (
          completed: analyticsTodos
              .where(
                (todo) => todo.category == category && todo.completedAt != null,
              )
              .length,
          total: analyticsTodos
              .where((todo) => todo.category == category)
              .length,
        ),
    };
  }

  Map<int, ({int completed, int total})> get priorityCompletionStats => {
    for (final priority in [2, 1, 0])
      priority: (
        completed: analyticsTodos
            .where(
              (todo) => todo.priority == priority && todo.completedAt != null,
            )
            .length,
        total: analyticsTodos.where((todo) => todo.priority == priority).length,
      ),
  };

  int get completedOnTimeCount => analyticsTodos
      .where(
        (todo) =>
            todo.completedAt != null &&
            !todo.completedAt!.isAfter(todo.deadlineAt),
      )
      .length;

  int get delayedCount => analyticsTodos
      .where(
        (todo) => todo.completedAt != null
            ? todo.completedAt!.isAfter(todo.deadlineAt)
            : currentTime.value.isAfter(todo.deadlineAt),
      )
      .length;

  DateTime _weekStart(int offset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: offset * 7));
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    searchTextController.dispose();
    calendarSearchTextController.dispose();
    super.onClose();
  }

  int get completedCount =>
      todos.where((todo) => todo.completedAt != null).length;
  double get completionRate =>
      todos.isEmpty ? 0 : completedCount / todos.length;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
