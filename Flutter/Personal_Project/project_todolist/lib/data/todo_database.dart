import 'dart:convert';

import 'package:path/path.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/model/todo_category.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/work_session.dart';
import 'package:sqflite/sqflite.dart';

/// 컨트롤러가 사용하는 Todo와 휴지통 영속성 기능을 정의합니다.
abstract interface class TodoRepository {
  Future<void> seedExamplesIfNeeded(DateTime today);
  Future<List<Todo>> readTodos();
  Future<List<TodoCategory>> readCategories();
  Future<int> insertCategory(String name);
  Future<void> updateCategory(int id, String name);
  Future<void> deleteCategory(int id);
  Future<List<Todo>> readAnalyticsTodos();
  Future<List<DeletedTodo>> readDeletedTodos();
  Future<int> insert(Todo todo);
  Future<void> update(Todo todo);
  Future<void> setTodoCompletion(int id, {required bool isCompleted});
  Future<void> moveToTrash(int id);
  Future<void> restoreTodo(int id);
  Future<void> restoreAllTodos();
  Future<void> permanentlyDeleteTodo(int id);
  Future<void> permanentlyDeleteAllTodos();
  Future<List<WorkSession>> readWorkSessions();
  Future<void> normalizeActiveWorkSessions();
  Future<int> insertWorkSession(WorkSession session);
  Future<void> updateWorkSession(WorkSession session);
  Future<List<Routine>> readRoutines();
  Future<int> insertRoutine(Routine routine);
  Future<void> updateRoutine(Routine routine);
  Future<void> deleteRoutine(
    int id, {
    required bool moveIncompleteTodosToTrash,
  });
  Future<void> createRoutineTodosFor(DateTime date);
  Future<void> syncRoutineTodos(DateTime today);
}

/// Todo와 휴지통 테이블 생성 및 CRUD를 전담하는 SQLite 저장소입니다.
class TodoDatabase implements TodoRepository {
  TodoDatabase._({this._databasePath});

  /// 실제 앱 DB와 분리된 경로에서 마이그레이션을 검증할 때 사용합니다.
  factory TodoDatabase.forTesting(String databasePath) =>
      TodoDatabase._(databasePath: databasePath);

  static final instance = TodoDatabase._();
  final String? _databasePath;
  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final path =
        _databasePath ?? join(await getDatabasesPath(), 'today_todo.db');
    return openDatabase(
      path,
      version: 11,
      onCreate: (db, version) async {
        await _createCategoriesTable(db);
        await _createTodosTable(db);
        await _createDeletedTodosTable(db);
        await _createWorkSessionsTable(db);
        await _createRoutinesTable(db);
        await _createAnalyticsSchema(db);
        await _createSingleActiveSessionIndex(db);
        await _createAppMetadataTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createDeletedTodosTable(db);
        if (oldVersion < 3) await _createWorkSessionsTable(db);
        if (oldVersion == 3) {
          await _addColumnIfMissing(
            db,
            table: 'work_sessions',
            column: 'paused_at',
            definition: 'TEXT',
          );
        }
        if (oldVersion < 5) {
          await _addColumnIfMissing(
            db,
            table: 'todos',
            column: 'routine_id',
            definition: 'INTEGER',
          );
          await _addColumnIfMissing(
            db,
            table: 'todos',
            column: 'routine_date',
            definition: 'TEXT',
          );
          await _addColumnIfMissing(
            db,
            table: 'deleted_todos',
            column: 'routine_id',
            definition: 'INTEGER',
          );
          await _addColumnIfMissing(
            db,
            table: 'deleted_todos',
            column: 'routine_date',
            definition: 'TEXT',
          );
          await _createRoutinesTable(db);
          await _createRoutineTodoIndex(db);
        }
        if (oldVersion < 6) {
          await _addColumnIfMissing(
            db,
            table: 'todos',
            column: 'created_at',
            definition: 'TEXT',
          );
          await _addColumnIfMissing(
            db,
            table: 'todos',
            column: 'completed_at',
            definition: 'TEXT',
          );
          await db.execute(
            "UPDATE todos SET created_at = datetime('now') WHERE created_at IS NULL",
          );
          await db.execute(
            "UPDATE todos SET completed_at = datetime('now') "
            'WHERE is_completed = 1 AND completed_at IS NULL',
          );
          await _addColumnIfMissing(
            db,
            table: 'deleted_todos',
            column: 'created_at',
            definition: 'TEXT',
          );
          await _addColumnIfMissing(
            db,
            table: 'deleted_todos',
            column: 'completed_at',
            definition: 'TEXT',
          );
          await db.execute(
            "UPDATE deleted_todos SET created_at = datetime('now') "
            'WHERE created_at IS NULL',
          );
          await db.execute(
            "UPDATE deleted_todos SET completed_at = datetime('now') "
            'WHERE is_completed = 1 AND completed_at IS NULL',
          );
        }
        if (oldVersion < 7) await _upgradeAnalyticsSchema(db);
        if (oldVersion < 8) await _repairTodoCompletionState(db);
        if (oldVersion < 9) {
          await _normalizeActiveWorkSessions(db);
          await _createSingleActiveSessionIndex(db);
        }
        if (oldVersion < 10) {
          await _createAppMetadataTable(db);
          await _createRoutineTodoIndex(db);
        }
        if (oldVersion < 11) {
          for (final table in ['todos', 'deleted_todos', 'routines']) {
            await _addColumnIfMissing(
              db,
              table: table,
              column: 'has_time',
              definition: 'INTEGER NOT NULL DEFAULT 1',
            );
          }
          await _createAnalyticsSchema(db);
        }
      },
    );
  }

  /// 테스트나 앱 종료 시 열린 DB 연결을 안전하게 닫습니다.
  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }

  /// 중간 실패 후 재실행되어도 기존 컬럼은 건너뛰어 데이터를 보존합니다.
  Future<void> _addColumnIfMissing(
    DatabaseExecutor db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<void> _createTodosTable(DatabaseExecutor db) => db.execute('''
    CREATE TABLE todos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      memo TEXT NOT NULL DEFAULT '',
      due_at TEXT NOT NULL,
      has_time INTEGER NOT NULL DEFAULT 1,
      category TEXT NOT NULL,
      priority INTEGER NOT NULL,
      estimated_minutes INTEGER NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      routine_id INTEGER,
      routine_date TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      category_id INTEGER,
      completed_at TEXT
    )
  ''');

  Future<void> _createDeletedTodosTable(DatabaseExecutor db) => db.execute('''
    CREATE TABLE IF NOT EXISTS deleted_todos(
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      memo TEXT NOT NULL DEFAULT '',
      due_at TEXT NOT NULL,
      has_time INTEGER NOT NULL DEFAULT 1,
      category TEXT NOT NULL,
      priority INTEGER NOT NULL,
      estimated_minutes INTEGER NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      deleted_at TEXT NOT NULL,
      routine_id INTEGER,
      routine_date TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      category_id INTEGER,
      completed_at TEXT
    )
  ''');

  Future<void> _createWorkSessionsTable(DatabaseExecutor db) => db.execute('''
    CREATE TABLE IF NOT EXISTS work_sessions(
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

  /// 실행·일시정지 세션이 DB 전체에서 하나만 존재하도록 보장합니다.
  Future<void> _createSingleActiveSessionIndex(DatabaseExecutor db) =>
      db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_single_active_work_session
        ON work_sessions((1))
        WHERE status IN ('running', 'paused')
      ''');

  /// 중복 활성 세션은 최신 한 건만 유지하고 나머지는 완료 기록으로 정리합니다.
  Future<void> _normalizeActiveWorkSessions(DatabaseExecutor db) async {
    final rows = await db.query(
      'work_sessions',
      where: "status IN ('running', 'paused')",
      orderBy: 'started_at DESC, id DESC',
    );
    if (rows.length < 2) return;
    final now = DateTime.now();
    for (final row in rows.skip(1)) {
      final session = WorkSession.fromMap(row);
      final elapsed = session.isRunning
          ? session.elapsedAt(now)
          : session.elapsedSeconds;
      await db.update(
        'work_sessions',
        {
          'elapsed_seconds': elapsed,
          'status': WorkSessionStatus.completed.name,
          'ends_at': null,
          'paused_at': null,
          'completed_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [session.id],
      );
      await _recordEvent(
        db,
        todoId: session.todoId,
        type: 'focus_completed',
        metadata: {
          'session_id': session.id,
          'elapsed_seconds': elapsed,
          'reason': 'duplicate_active_session_cleanup',
        },
      );
    }
  }

  Future<void> _createRoutinesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS routines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        memo TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL,
        priority INTEGER NOT NULL,
        estimated_minutes INTEGER NOT NULL,
        scheduled_hour INTEGER NOT NULL,
        scheduled_minute INTEGER NOT NULL,
        has_time INTEGER NOT NULL DEFAULT 1,
        repeat_days TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
        ,category_id INTEGER
      )
    ''');
    await _createRoutineTodoIndex(db);
  }

  Future<void> _createRoutineTodoIndex(DatabaseExecutor db) => db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_todos_routine_date
    ON todos(routine_id, routine_date)
  ''');

  /// 루틴의 마지막 동기화 날짜를 저장해 미접속 기간만 보완합니다.
  Future<void> _createAppMetadataTable(DatabaseExecutor db) => db.execute('''
    CREATE TABLE IF NOT EXISTS app_metadata(
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');

  /// 기존 문자열 카테고리를 유지하면서 분석에 사용할 식별자를 제공합니다.
  Future<void> _createCategoriesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color INTEGER,
        created_at TEXT NOT NULL
      )
    ''');
    for (final name in ['업무', '개인', '건강', '학습']) {
      await db.insert('categories', {
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  /// 분석 이벤트, 조회 인덱스와 통합 View를 반복 실행 가능하게 생성합니다.
  Future<void> _createAnalyticsSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todo_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todo_id INTEGER NOT NULL,
        event_type TEXT NOT NULL,
        occurred_at TEXT NOT NULL,
        field_name TEXT,
        old_value TEXT,
        new_value TEXT,
        metadata_json TEXT
      )
    ''');
    for (final sql in [
      'CREATE INDEX IF NOT EXISTS idx_todos_created_at ON todos(created_at)',
      'CREATE INDEX IF NOT EXISTS idx_todos_completed_at ON todos(completed_at)',
      'CREATE INDEX IF NOT EXISTS idx_todos_due_at ON todos(due_at)',
      'CREATE INDEX IF NOT EXISTS idx_todos_category_id ON todos(category_id)',
      'CREATE INDEX IF NOT EXISTS idx_todos_priority ON todos(priority)',
      'CREATE INDEX IF NOT EXISTS idx_sessions_todo_id ON work_sessions(todo_id)',
      'CREATE INDEX IF NOT EXISTS idx_sessions_completed_at ON work_sessions(completed_at)',
      'CREATE INDEX IF NOT EXISTS idx_events_todo_id ON todo_events(todo_id)',
      'CREATE INDEX IF NOT EXISTS idx_events_occurred_at ON todo_events(occurred_at)',
      'CREATE INDEX IF NOT EXISTS idx_events_type ON todo_events(event_type)',
    ]) {
      await db.execute(sql);
    }
    await db.execute('DROP VIEW IF EXISTS todo_analytics');
    await db.execute('''
      CREATE VIEW todo_analytics AS
      SELECT id, title, category, category_id, priority, due_at, has_time, created_at,
             updated_at, completed_at, is_completed, routine_id,
             NULL AS deleted_at
      FROM todos
      UNION ALL
      SELECT id, title, category, category_id, priority, due_at, has_time, created_at,
             updated_at, completed_at, is_completed, routine_id, deleted_at
      FROM deleted_todos
    ''');
  }

  /// 버전 7의 분석 필드를 기존 데이터를 잃지 않고 보강합니다.
  Future<void> _upgradeAnalyticsSchema(DatabaseExecutor db) async {
    for (final table in ['todos', 'deleted_todos']) {
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'updated_at',
        definition: 'TEXT',
      );
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'category_id',
        definition: 'INTEGER',
      );
      await db.execute(
        'UPDATE $table SET updated_at = COALESCE(created_at, ?) '
        'WHERE updated_at IS NULL',
        [DateTime.now().toIso8601String()],
      );
    }
    await _addColumnIfMissing(
      db,
      table: 'routines',
      column: 'category_id',
      definition: 'INTEGER',
    );
    await _createCategoriesTable(db);
    for (final table in ['todos', 'deleted_todos', 'routines']) {
      await db.execute('''
        UPDATE $table
        SET category_id = (
          SELECT id FROM categories WHERE categories.name = $table.category
        )
        WHERE category_id IS NULL
      ''');
    }
    await _createAnalyticsSchema(db);
  }

  /// 완료 시각을 기준으로 기존 Todo의 완료 플래그 불일치를 교정합니다.
  Future<void> _repairTodoCompletionState(DatabaseExecutor db) async {
    for (final table in ['todos', 'deleted_todos']) {
      await db.execute('''
        UPDATE $table
        SET is_completed = CASE WHEN completed_at IS NULL THEN 0 ELSE 1 END
      ''');
    }
  }

  /// 이름으로 카테고리 ID를 찾고 사용자 정의 값이면 자동 등록합니다.
  Future<int?> _categoryIdFor(DatabaseExecutor db, String name) async {
    if (name == '없음') return null;
    await db.insert('categories', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    final rows = await db.query(
      'categories',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return rows.single['id'] as int;
  }

  /// 사용자 카테고리만 등록 순서대로 불러옵니다. `없음`은 UI 고정 항목입니다.
  @override
  Future<List<TodoCategory>> readCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(TodoCategory.fromMap).toList();
  }

  /// 검증된 이름으로 사용자 카테고리를 추가합니다.
  @override
  Future<int> insertCategory(String name) async {
    final db = await database;
    return db.insert('categories', {
      'name': name.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// 카테고리 이름과 연결된 Todo·루틴의 표시 문자열을 함께 변경합니다.
  @override
  Future<void> updateCategory(int id, String name) async {
    final db = await database;
    await db.transaction((txn) async {
      final normalized = name.trim();
      await txn.update(
        'categories',
        {'name': normalized},
        where: 'id = ?',
        whereArgs: [id],
      );
      for (final table in ['todos', 'deleted_todos', 'routines']) {
        await txn.update(
          table,
          {'category': normalized},
          where: 'category_id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  /// 연결된 모든 일정은 `없음`으로 옮긴 뒤 카테고리를 삭제합니다.
  @override
  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in ['todos', 'deleted_todos', 'routines']) {
        await txn.update(
          table,
          {'category': '없음', 'category_id': null},
          where: 'category_id = ?',
          whereArgs: [id],
        );
      }
      await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Todo 상태 변화 한 건을 영구 분석 이력으로 남깁니다.
  Future<void> _recordEvent(
    DatabaseExecutor db, {
    required int todoId,
    required String type,
    String? field,
    Object? oldValue,
    Object? newValue,
    Map<String, Object?>? metadata,
  }) => db.insert('todo_events', {
    'todo_id': todoId,
    'event_type': type,
    'occurred_at': DateTime.now().toIso8601String(),
    'field_name': field,
    'old_value': oldValue?.toString(),
    'new_value': newValue?.toString(),
    'metadata_json': metadata == null ? null : jsonEncode(metadata),
  });

  /// 영상 시연에 필요한 Todo·루틴·집중·휴지통 데이터를 최초 한 번 생성합니다.
  @override
  Future<void> seedExamplesIfNeeded(DateTime today) async {
    final db = await database;
    await db.transaction((txn) async {
      await _createAppMetadataTable(txn);
      const metadataKey = 'video_demo_seeded_v1';
      final seeded = await txn.query(
        'app_metadata',
        columns: ['key'],
        where: 'key = ?',
        whereArgs: [metadataKey],
        limit: 1,
      );
      if (seeded.isNotEmpty) return;

      final day = DateTime(today.year, today.month, today.day);
      final now = today;
      final nowText = now.toIso8601String();
      await txn.insert('app_metadata', {'key': metadataKey, 'value': nowText});
      await _categoryIdFor(txn, '취미');

      Future<int> insertExample(Todo todo) async {
        final values = todo.toMap()
          ..remove('id')
          ..['category_id'] = await _categoryIdFor(txn, todo.category)
          ..['created_at'] = (todo.createdAt ?? now).toIso8601String()
          ..['updated_at'] = nowText
          ..['is_completed'] = todo.isCompleted ? 1 : 0
          ..['completed_at'] = todo.completedAt?.toIso8601String();
        final id = await txn.insert('todos', values);
        await _recordEvent(txn, todoId: id, type: 'created');
        if (todo.isCompleted) {
          await _recordEvent(txn, todoId: id, type: 'completed');
        }
        return id;
      }

      final focusTodoId = await insertExample(
        Todo(
          title: '프로젝트 발표 자료 정리',
          memo: '핵심 기능과 구현 과정을 슬라이드로 정리하기',
          dueAt: DateTime(day.year, day.month, day.day, 23, 59),
          category: '업무',
          priority: 2,
          estimatedMinutes: 60,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      );
      await insertExample(
        Todo(
          title: '주말 장보기 목록 확인',
          memo: '우유, 과일, 세제 확인하기',
          dueAt: day,
          hasTime: false,
          category: '개인',
          priority: 1,
          estimatedMinutes: 0,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      );
      await insertExample(
        Todo(
          title: '지난 회의록 내용 보완',
          memo: '결정 사항과 담당자 항목 추가하기',
          dueAt: DateTime(day.year, day.month, day.day - 1, 18),
          category: '업무',
          priority: 2,
          estimatedMinutes: 30,
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      );
      await insertExample(
        Todo(
          title: '아침 러닝 3km',
          dueAt: DateTime(day.year, day.month, day.day, 8),
          category: '건강',
          priority: 1,
          estimatedMinutes: 30,
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 1)),
          completedAt: DateTime(day.year, day.month, day.day, 7, 45),
        ),
      );
      await insertExample(
        Todo(
          title: 'Flutter 상태 관리 복습',
          memo: 'GetX 반응형 상태 흐름 다시 정리하기',
          dueAt: DateTime(day.year, day.month, day.day - 1, 21),
          category: '학습',
          priority: 0,
          estimatedMinutes: 45,
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 4)),
          completedAt: DateTime(day.year, day.month, day.day - 1, 20, 30),
        ),
      );

      await txn.insert(
        'work_sessions',
        WorkSession(
          todoId: focusTodoId,
          plannedSeconds: 60 * 60,
          elapsedSeconds: 20 * 60,
          startedAt: now.subtract(const Duration(hours: 2)),
          status: WorkSessionStatus.completed,
          completedAt: now.subtract(const Duration(hours: 1, minutes: 40)),
        ).toMap()..remove('id'),
      );

      for (final routine in [
        Routine(
          title: '아침 물 한 잔과 스트레칭',
          memo: '하루를 시작하기 전에 가볍게 몸 풀기',
          category: '건강',
          priority: 0,
          estimatedMinutes: 10,
          scheduledHour: 0,
          scheduledMinute: 0,
          hasTime: false,
          repeatDays: const {1, 2, 3, 4, 5, 6, 7},
          startDate: day,
          createdAt: now,
        ),
        Routine(
          title: '하루 계획과 회고 작성',
          memo: '오늘의 핵심 목표와 완료 내용을 기록하기',
          category: '취미',
          priority: 1,
          estimatedMinutes: 15,
          scheduledHour: 0,
          scheduledMinute: 0,
          hasTime: false,
          repeatDays: const {1, 2, 3, 4, 5, 6, 7},
          startDate: day,
          createdAt: now,
        ),
      ]) {
        final values = routine.toMap()
          ..remove('id')
          ..['category_id'] = await _categoryIdFor(txn, routine.category);
        await txn.insert('routines', values);
      }

      final trashId = await insertExample(
        Todo(
          title: '사용하지 않는 메모 정리',
          dueAt: day,
          hasTime: false,
          category: '없음',
          estimatedMinutes: 0,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      );
      await txn.rawInsert(
        '''
        INSERT INTO deleted_todos(
          id, title, memo, due_at, has_time, category, priority,
          estimated_minutes, is_completed, deleted_at, routine_id,
          routine_date, created_at, updated_at, category_id, completed_at
        )
        SELECT id, title, memo, due_at, has_time, category, priority,
          estimated_minutes, is_completed, ?, routine_id,
          routine_date, created_at, updated_at, category_id, completed_at
        FROM todos WHERE id = ?
      ''',
        [nowText, trashId],
      );
      await txn.delete('todos', where: 'id = ?', whereArgs: [trashId]);
      await _recordEvent(txn, todoId: trashId, type: 'deleted');
    });
  }

  @override
  Future<List<Todo>> readTodos() async {
    final db = await database;
    final rows = await db.query('todos', orderBy: 'due_at ASC');
    return rows.map(Todo.fromMap).toList();
  }

  /// 활성 목록과 휴지통을 합친 View에서 과거 통계용 Todo를 읽습니다.
  /// 영구 삭제된 Todo는 집계에서 제외되지만 todo_events 감사 이력은 유지됩니다.
  @override
  Future<List<Todo>> readAnalyticsTodos() async {
    final db = await database;
    final rows = await db.query('todo_analytics', orderBy: 'created_at ASC');
    return rows.map(Todo.fromMap).toList();
  }

  @override
  Future<List<DeletedTodo>> readDeletedTodos() async {
    final db = await database;
    final rows = await db.query('deleted_todos', orderBy: 'deleted_at DESC');
    return rows.map(DeletedTodo.fromMap).toList();
  }

  @override
  Future<int> insert(Todo todo) async {
    final db = await database;
    return db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final values = todo.toMap()
        ..remove('id')
        ..['category_id'] = await _categoryIdFor(txn, todo.category)
        ..['created_at'] = (todo.createdAt ?? DateTime.now()).toIso8601String()
        ..['updated_at'] = now
        ..['is_completed'] = todo.isCompleted ? 1 : 0
        ..['completed_at'] = todo.isCompleted
            ? (todo.completedAt ?? DateTime.now()).toIso8601String()
            : null;
      final id = await txn.insert('todos', values);
      await _recordEvent(txn, todoId: id, type: 'created');
      return id;
    });
  }

  @override
  Future<void> update(Todo todo) async {
    final db = await database;
    if (todo.id == null) return;
    await db.transaction((txn) async {
      final before = await txn.query(
        'todos',
        where: 'id = ?',
        whereArgs: [todo.id],
        limit: 1,
      );
      if (before.isEmpty) return;
      final old = Todo.fromMap(before.single);
      final completedAt = todo.isCompleted
          ? todo.completedAt ?? DateTime.now()
          : null;
      final values = todo.toMap()
        ..['category_id'] = await _categoryIdFor(txn, todo.category)
        ..['updated_at'] = DateTime.now().toIso8601String()
        ..['is_completed'] = completedAt == null ? 0 : 1
        ..['completed_at'] = completedAt?.toIso8601String();
      await txn.update('todos', values, where: 'id = ?', whereArgs: [todo.id]);
      await _recordEvent(txn, todoId: todo.id!, type: 'updated');
      final wasCompleted = old.completedAt != null;
      final isCompleted = completedAt != null;
      if (wasCompleted != isCompleted) {
        await _recordEvent(
          txn,
          todoId: todo.id!,
          type: isCompleted ? 'completed' : 'reopened',
          field: 'is_completed',
          oldValue: wasCompleted ? 1 : 0,
          newValue: isCompleted ? 1 : 0,
        );
      }
      await _recordChangedField(
        txn,
        todo.id!,
        'due_date_changed',
        'due_at',
        old.dueAt.toIso8601String(),
        todo.dueAt.toIso8601String(),
      );
      await _recordChangedField(
        txn,
        todo.id!,
        'priority_changed',
        'priority',
        old.priority,
        todo.priority,
      );
      await _recordChangedField(
        txn,
        todo.id!,
        'category_changed',
        'category',
        old.category,
        todo.category,
      );
    });
  }

  /// 완료 상태와 완료 시각을 하나의 트랜잭션에서 함께 변경합니다.
  @override
  Future<void> setTodoCompletion(int id, {required bool isCompleted}) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'todos',
        columns: ['completed_at'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final wasCompleted = rows.single['completed_at'] != null;
      if (wasCompleted == isCompleted) return;
      final now = DateTime.now().toIso8601String();
      await txn.update(
        'todos',
        {
          'is_completed': isCompleted ? 1 : 0,
          'completed_at': isCompleted ? now : null,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await _recordEvent(
        txn,
        todoId: id,
        type: isCompleted ? 'completed' : 'reopened',
        field: 'is_completed',
        oldValue: wasCompleted ? 1 : 0,
        newValue: isCompleted ? 1 : 0,
      );
    });
  }

  Future<void> _recordChangedField(
    DatabaseExecutor db,
    int todoId,
    String type,
    String field,
    Object oldValue,
    Object newValue,
  ) async {
    if (oldValue == newValue) return;
    await _recordEvent(
      db,
      todoId: todoId,
      type: type,
      field: field,
      oldValue: oldValue,
      newValue: newValue,
    );
  }

  /// 활성 Todo를 원래 ID와 함께 휴지통으로 안전하게 이동합니다.
  @override
  Future<void> moveToTrash(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await _moveTodoToTrash(txn, id, DateTime.now());
    });
  }

  /// 같은 트랜잭션 안에서 집중 세션을 정리하고 Todo를 휴지통으로 이동합니다.
  Future<void> _moveTodoToTrash(
    DatabaseExecutor db,
    int id,
    DateTime now,
  ) async {
    final rows = await db.query('todos', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final activeSessions = await db.query(
      'work_sessions',
      where: "todo_id = ? AND status IN ('running', 'paused')",
      whereArgs: [id],
    );
    for (final row in activeSessions) {
      final session = WorkSession.fromMap(row);
      final elapsed = session.isRunning
          ? session.elapsedAt(now)
          : session.elapsedSeconds;
      await db.update(
        'work_sessions',
        {
          'elapsed_seconds': elapsed,
          'status': WorkSessionStatus.completed.name,
          'ends_at': null,
          'paused_at': null,
          'completed_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [session.id],
      );
      await _recordEvent(
        db,
        todoId: id,
        type: 'focus_completed',
        metadata: {
          'session_id': session.id,
          'elapsed_seconds': elapsed,
          'reason': 'todo_deleted',
        },
      );
    }
    await db.insert('deleted_todos', {
      ...rows.single,
      'deleted_at': now.toIso8601String(),
    });
    await _recordEvent(db, todoId: id, type: 'deleted');
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  /// 휴지통 Todo를 원래 ID로 복구해 기존 정렬 위치를 보존합니다.
  @override
  Future<void> restoreTodo(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'deleted_todos',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rows.isEmpty) return;
      final values = Map<String, Object?>.from(rows.single)
        ..remove('deleted_at');
      await txn.insert('todos', values);
      await _recordEvent(txn, todoId: id, type: 'restored');
      await txn.delete('deleted_todos', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// 휴지통의 모든 Todo를 하나의 트랜잭션에서 복구합니다.
  @override
  Future<void> restoreAllTodos() async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('deleted_todos');
      for (final row in rows) {
        final id = row['id'] as int;
        final values = Map<String, Object?>.from(row)..remove('deleted_at');
        await txn.insert('todos', values);
        await _recordEvent(txn, todoId: id, type: 'restored');
      }
      await txn.delete('deleted_todos');
    });
  }

  /// 휴지통에서 선택한 Todo를 복구할 수 없도록 제거합니다.
  @override
  Future<void> permanentlyDeleteTodo(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      final count = await txn.delete(
        'deleted_todos',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count > 0) {
        await _recordEvent(txn, todoId: id, type: 'permanently_deleted');
      }
    });
  }

  /// 휴지통의 모든 Todo를 영구 삭제하고 각 삭제 이력을 남깁니다.
  @override
  Future<void> permanentlyDeleteAllTodos() async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('deleted_todos', columns: ['id']);
      await txn.delete('deleted_todos');
      for (final row in rows) {
        await _recordEvent(
          txn,
          todoId: row['id'] as int,
          type: 'permanently_deleted',
        );
      }
    });
  }

  @override
  Future<List<WorkSession>> readWorkSessions() async {
    final db = await database;
    final rows = await db.query('work_sessions', orderBy: 'started_at DESC');
    return rows.map(WorkSession.fromMap).toList();
  }

  @override
  Future<void> normalizeActiveWorkSessions() async {
    final db = await database;
    await db.transaction((txn) => _normalizeActiveWorkSessions(txn));
    await _createSingleActiveSessionIndex(db);
  }

  @override
  Future<int> insertWorkSession(WorkSession session) async {
    final db = await database;
    return db.transaction((txn) async {
      final values = session.toMap()..remove('id');
      final id = await txn.insert('work_sessions', values);
      await _recordEvent(
        txn,
        todoId: session.todoId,
        type: 'focus_started',
        metadata: {'session_id': id, 'planned_seconds': session.plannedSeconds},
      );
      return id;
    });
  }

  @override
  Future<void> updateWorkSession(WorkSession session) async {
    final db = await database;
    await db.transaction((txn) async {
      final before = await txn.query(
        'work_sessions',
        where: 'id = ?',
        whereArgs: [session.id],
        limit: 1,
      );
      await txn.update(
        'work_sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
      final oldStatus = before.isEmpty ? null : before.single['status'];
      if (session.status == WorkSessionStatus.completed &&
          oldStatus != WorkSessionStatus.completed.name) {
        await _recordEvent(
          txn,
          todoId: session.todoId,
          type: 'focus_completed',
          metadata: {
            'session_id': session.id,
            'elapsed_seconds': session.elapsedSeconds,
          },
        );
      }
    });
  }

  @override
  Future<List<Routine>> readRoutines() async {
    final db = await database;
    final rows = await db.query('routines', orderBy: 'created_at DESC');
    return rows.map(Routine.fromMap).toList();
  }

  @override
  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    final values = routine.toMap()
      ..remove('id')
      ..['category_id'] = await _categoryIdFor(db, routine.category);
    return db.insert('routines', values);
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    final db = await database;
    final values = routine.toMap()
      ..['category_id'] = await _categoryIdFor(db, routine.category);
    await db.update(
      'routines',
      values,
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  /// 루틴 삭제 후에도 이미 생성된 Todo와 집중 기록은 보존합니다.
  @override
  Future<void> deleteRoutine(
    int id, {
    required bool moveIncompleteTodosToTrash,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      if (moveIncompleteTodosToTrash) {
        final rows = await txn.query(
          'todos',
          columns: ['id'],
          where: 'routine_id = ? AND completed_at IS NULL',
          whereArgs: [id],
        );
        final now = DateTime.now();
        for (final row in rows) {
          await _moveTodoToTrash(txn, row['id'] as int, now);
        }
      }
      await txn.delete('routines', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// 해당 날짜의 반복 조건에 맞는 Todo를 중복 없이 생성합니다.
  @override
  Future<void> createRoutineTodosFor(DateTime date) async {
    final db = await database;
    final day = DateTime(date.year, date.month, date.day);
    await db.transaction((txn) => _createRoutineTodosForDate(txn, day));
  }

  /// 미접속 기간을 보완하고 앞으로 30일의 캘린더 일정을 준비합니다.
  @override
  Future<void> syncRoutineTodos(DateTime today) async {
    final db = await database;
    final currentDay = DateTime(today.year, today.month, today.day);
    await db.transaction((txn) async {
      await _createAppMetadataTable(txn);
      final tomorrow = currentDay.add(const Duration(days: 1));

      // 이전 버전에서 미리 생성한 미래 일정은 가상 캘린더 일정으로 대체합니다.
      await txn.delete(
        'todos',
        where:
            'routine_id IS NOT NULL AND completed_at IS NULL AND due_at >= ?',
        whereArgs: [tomorrow.toIso8601String()],
      );
      await _createRoutineTodosForDate(txn, currentDay);
      await txn.insert('app_metadata', {
        'key': 'routine_last_sync_date',
        'value': currentDay.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> _createRoutineTodosForDate(
    DatabaseExecutor db,
    DateTime day,
  ) async {
    final rows = await db.query('routines', where: 'is_active = 1');
    for (final row in rows) {
      final routine = Routine.fromMap(row);
      if (!routine.appliesTo(day)) continue;
      final routineDate = day.toIso8601String();
      final deleted = await db.query(
        'deleted_todos',
        columns: ['id'],
        where: 'routine_id = ? AND routine_date = ?',
        whereArgs: [routine.id, routineDate],
        limit: 1,
      );
      if (deleted.isNotEmpty) continue;
      await db.insert('todos', {
        'title': routine.title,
        'memo': routine.memo,
        'due_at': DateTime(
          day.year,
          day.month,
          day.day,
          routine.scheduledHour,
          routine.scheduledMinute,
        ).toIso8601String(),
        'has_time': routine.hasTime ? 1 : 0,
        'category': routine.category,
        'category_id':
            routine.categoryId ?? await _categoryIdFor(db, routine.category),
        'priority': routine.priority,
        'estimated_minutes': routine.estimatedMinutes,
        'is_completed': 0,
        'routine_id': routine.id,
        'routine_date': routineDate,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'completed_at': null,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
