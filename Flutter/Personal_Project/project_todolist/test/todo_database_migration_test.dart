import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:project_todolist/data/todo_database.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('todo_migration_');
    databasePath = path.join(tempDirectory.path, 'today_todo.db');
    await _createVersion6Database(databasePath);
  });

  tearDown(() async {
    await databaseFactoryFfi.deleteDatabase(databasePath);
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('버전 6 DB를 현재 버전으로 반복 업그레이드해도 데이터와 분석 구조를 유지한다', () async {
    var repository = TodoDatabase.forTesting(databasePath);
    var database = await repository.database;

    expect(await database.getVersion(), 11);
    expect((await repository.readTodos()).single.title, '기존 Todo');
    await _expectAnalyticsSchema(database);

    final todoId = await repository.insert(
      Todo(title: '이벤트 확인', dueAt: DateTime(2026, 9, 2, 18), hasTime: false),
    );
    await repository.setTodoCompletion(todoId, isCompleted: true);
    await repository.moveToTrash(todoId);
    await repository.restoreTodo(todoId);

    final eventRows = await database.query(
      'todo_events',
      columns: ['event_type'],
      where: 'todo_id = ?',
      whereArgs: [todoId],
      orderBy: 'id ASC',
    );
    expect(eventRows.map((row) => row['event_type']), [
      'created',
      'completed',
      'deleted',
      'restored',
    ]);

    await repository.close();
    database = await databaseFactoryFfi.openDatabase(databasePath);
    await database.execute('PRAGMA user_version = 6');
    await database.close();

    repository = TodoDatabase.forTesting(databasePath);
    database = await repository.database;
    expect(await database.getVersion(), 11);
    expect(
      (await repository.readTodos())
          .singleWhere((todo) => todo.id == todoId)
          .hasTime,
      isFalse,
    );
    expect((await repository.readTodos()).map((todo) => todo.title), [
      '기존 Todo',
      '이벤트 확인',
    ]);
    await _expectAnalyticsSchema(database);
    await repository.close();
  });

  test('개발용 예시 Todo는 최초 한 번만 생성한다', () async {
    final examplePath = path.join(tempDirectory.path, 'examples.db');
    final repository = TodoDatabase.forTesting(examplePath);
    final today = DateTime(2026, 9, 4, 9);

    await repository.seedExamplesIfNeeded(today);
    var examples = await repository.readTodos();
    expect(examples, hasLength(5));
    expect(
      examples.map((todo) => todo.title),
      containsAll([
        '프로젝트 발표 자료 정리',
        '주말 장보기 목록 확인',
        '지난 회의록 내용 보완',
        '아침 러닝 3km',
        'Flutter 상태 관리 복습',
      ]),
    );
    expect(examples.where((todo) => todo.isCompleted), hasLength(2));
    expect(examples.where((todo) => !todo.hasTime), hasLength(1));
    expect(await repository.readWorkSessions(), hasLength(1));
    expect(await repository.readDeletedTodos(), hasLength(1));
    expect(await repository.readCategories(), hasLength(5));
    expect(await repository.readRoutines(), hasLength(2));
    expect(
      (await repository.readRoutines()).map((routine) => routine.title),
      containsAll(['아침 물 한 잔과 스트레칭', '하루 계획과 회고 작성']),
    );

    for (final todo in examples) {
      await repository.moveToTrash(todo.id!);
    }
    await repository.permanentlyDeleteAllTodos();
    await repository.seedExamplesIfNeeded(today);
    examples = await repository.readTodos();
    expect(examples, isEmpty);
    expect(await repository.readRoutines(), hasLength(2));
    await repository.close();
  });

  test('카테고리 없는 Todo는 표시값만 저장하고 카테고리 ID를 비워 둔다', () async {
    final repository = TodoDatabase.forTesting(databasePath);
    final todoId = await repository.insert(
      Todo(title: '분류 없는 할 일', dueAt: DateTime(2026, 9, 4)),
    );

    final saved = (await repository.readTodos()).singleWhere(
      (todo) => todo.id == todoId,
    );
    expect(saved.category, '없음');
    expect(saved.categoryId, isNull);
    await repository.close();
  });

  test('카테고리 수정과 삭제를 연결된 Todo·휴지통·루틴에 함께 반영한다', () async {
    final repository = TodoDatabase.forTesting(databasePath);
    final categoryId = await repository.insertCategory('프로젝트');
    final todoId = await repository.insert(
      Todo(title: '프로젝트 할 일', dueAt: DateTime(2026, 9, 4), category: '프로젝트'),
    );
    await repository.insertRoutine(
      Routine(
        title: '프로젝트 루틴',
        category: '프로젝트',
        scheduledHour: 9,
        scheduledMinute: 0,
        repeatDays: const {1},
        startDate: DateTime(2026, 9, 1),
        createdAt: DateTime(2026, 9, 1),
      ),
    );
    await repository.moveToTrash(todoId);

    await repository.updateCategory(categoryId, '사이드 프로젝트');
    expect(
      (await repository.readDeletedTodos()).single.todo.category,
      '사이드 프로젝트',
    );
    expect((await repository.readRoutines()).single.category, '사이드 프로젝트');

    await repository.deleteCategory(categoryId);
    final deletedTodo = (await repository.readDeletedTodos()).single.todo;
    expect(deletedTodo.category, '없음');
    expect(deletedTodo.categoryId, isNull);
    final routine = (await repository.readRoutines()).single;
    expect(routine.category, '없음');
    expect(routine.categoryId, isNull);
    expect(
      (await repository.readCategories()).map((category) => category.name),
      isNot(contains('사이드 프로젝트')),
    );
    await repository.close();
  });

  test('루틴 삭제 시 미완료 일정만 휴지통으로 이동한다', () async {
    final repository = TodoDatabase.forTesting(databasePath);
    final today = DateTime.now();
    final routineId = await repository.insertRoutine(
      Routine(
        title: '삭제할 루틴',
        scheduledHour: 9,
        scheduledMinute: 0,
        repeatDays: {today.weekday},
        startDate: today,
        createdAt: today,
      ),
    );
    await repository.createRoutineTodosFor(today);
    final completedId = await repository.insert(
      Todo(
        title: '완료된 루틴 일정',
        dueAt: today,
        routineId: routineId,
        routineDate: today.subtract(const Duration(days: 1)),
        isCompleted: true,
        completedAt: today,
      ),
    );

    await repository.deleteRoutine(routineId, moveIncompleteTodosToTrash: true);

    expect((await repository.readRoutines()), isEmpty);
    expect(
      (await repository.readTodos()).map((todo) => todo.id),
      contains(completedId),
    );
    expect((await repository.readDeletedTodos()), hasLength(1));
    await repository.close();
  });

  test('루틴은 오늘 일정만 생성하고 삭제한 일정은 다시 만들지 않는다', () async {
    final repository = TodoDatabase.forTesting(databasePath);
    final database = await repository.database;
    final today = DateTime(2026, 9, 3);
    final routineId = await repository.insertRoutine(
      Routine(
        title: '매일 동기화 루틴',
        scheduledHour: 9,
        scheduledMinute: 0,
        repeatDays: {1, 2, 3, 4, 5, 6, 7},
        startDate: today.subtract(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 2)),
      ),
    );
    await database.insert('app_metadata', {
      'key': 'routine_last_sync_date',
      'value': today.subtract(const Duration(days: 2)).toIso8601String(),
    });

    await repository.createRoutineTodosFor(today.add(const Duration(days: 1)));
    expect(
      (await repository.readTodos()).where(
        (todo) => DateUtils.isSameDay(
          todo.routineDate,
          today.add(const Duration(days: 1)),
        ),
      ),
      hasLength(1),
    );

    await repository.syncRoutineTodos(today);
    var generated = (await repository.readTodos())
        .where((todo) => todo.routineId == routineId)
        .toList();
    expect(generated, hasLength(1));

    final todayTodo = generated.singleWhere(
      (todo) => DateUtils.isSameDay(todo.routineDate, today),
    );
    await repository.moveToTrash(todayTodo.id!);
    await repository.syncRoutineTodos(today);

    generated = (await repository.readTodos())
        .where((todo) => todo.routineId == routineId)
        .toList();
    expect(generated, isEmpty);
    expect(await repository.readDeletedTodos(), hasLength(1));
    await repository.close();
  });
}

/// 버전 6 당시의 테이블과 기존 사용자 데이터를 임시 DB에 구성합니다.
Future<void> _createVersion6Database(String databasePath) async {
  final database = await databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: 6,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            memo TEXT NOT NULL DEFAULT '',
            due_at TEXT NOT NULL,
            category TEXT NOT NULL,
            priority INTEGER NOT NULL,
            estimated_minutes INTEGER NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            routine_id INTEGER,
            routine_date TEXT,
            created_at TEXT NOT NULL,
            completed_at TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE deleted_todos(
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            memo TEXT NOT NULL DEFAULT '',
            due_at TEXT NOT NULL,
            category TEXT NOT NULL,
            priority INTEGER NOT NULL,
            estimated_minutes INTEGER NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            deleted_at TEXT NOT NULL,
            routine_id INTEGER,
            routine_date TEXT,
            created_at TEXT NOT NULL,
            completed_at TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE work_sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            todo_id INTEGER NOT NULL,
            planned_seconds INTEGER NOT NULL,
            elapsed_seconds INTEGER NOT NULL DEFAULT 0,
            started_at TEXT NOT NULL,
            status TEXT NOT NULL,
            ends_at TEXT,
            paused_at TEXT,
            completed_at TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE routines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            memo TEXT NOT NULL DEFAULT '',
            category TEXT NOT NULL,
            priority INTEGER NOT NULL,
            estimated_minutes INTEGER NOT NULL,
            scheduled_hour INTEGER NOT NULL,
            scheduled_minute INTEGER NOT NULL,
            repeat_days TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');
        await database.insert('todos', {
          'title': '기존 Todo',
          'memo': '업그레이드 후에도 유지',
          'due_at': DateTime(2026, 9, 2, 12).toIso8601String(),
          'category': '업무',
          'priority': 1,
          'estimated_minutes': 30,
          'is_completed': 0,
          'created_at': DateTime(2026, 9, 1).toIso8601String(),
        });
      },
    ),
  );
  await database.close();
}

/// 분석용 테이블과 View가 실제 SQLite 스키마에 존재하는지 확인합니다.
Future<void> _expectAnalyticsSchema(Database database) async {
  final objects = await database.query(
    'sqlite_master',
    columns: ['name', 'type'],
    where: 'name IN (?, ?, ?, ?)',
    whereArgs: ['categories', 'todo_events', 'todo_analytics', 'app_metadata'],
  );
  final byName = {for (final row in objects) row['name']: row['type']};
  expect(byName['categories'], 'table');
  expect(byName['todo_events'], 'table');
  expect(byName['todo_analytics'], 'view');
  expect(byName['app_metadata'], 'table');
  for (final table in ['todos', 'deleted_todos', 'routines']) {
    final columns = await database.rawQuery('PRAGMA table_info($table)');
    expect(columns.map((row) => row['name']), contains('has_time'));
  }
}
