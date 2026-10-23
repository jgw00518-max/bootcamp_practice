import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../model/todo.dart';
import '../repository/todo_repository.dart';

/// SQLite를 이용해 Todo와 휴지통 데이터를 영구 저장하는 저장소다.
class TodoDatabase implements TodoRepository {
  TodoDatabase._();

  static const _databaseName = 'todo_list.db';
  static const _databaseVersion = 3;
  static const _todosTable = 'todos';
  static const _deletedTodosTable = 'deleted_todos';

  /// 앱 전체에서 하나의 데이터베이스 연결을 공유하는 싱글턴 인스턴스다.
  static final TodoDatabase instance = TodoDatabase._();

  Database? _database;

  /// 데이터베이스를 최초 한 번 열고 필요한 스키마를 준비한다.
  Future<Database> get _db async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    return _database!;
  }

  /// 새 데이터베이스에 현재 버전의 테이블을 생성한다.
  static Future<void> _createDatabase(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $_todosTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        created_date TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');
    await _createDeletedTodosTable(database);
  }

  /// 기존 데이터는 보존하면서 순서 및 휴지통 스키마를 단계별로 추가한다.
  static Future<void> _upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await database.execute(
        'ALTER TABLE $_todosTable '
        'ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0',
      );
      final rows = await database.query(_todosTable, orderBy: 'id DESC');
      final batch = database.batch();
      for (var index = 0; index < rows.length; index++) {
        batch.update(
          _todosTable,
          {'sort_order': index},
          where: 'id = ?',
          whereArgs: [rows[index]['id']],
        );
      }
      await batch.commit(noResult: true);
    }
    if (oldVersion < 3) await _createDeletedTodosTable(database);
  }

  static Future<void> _createDeletedTodosTable(Database database) {
    return database.execute('''
      CREATE TABLE IF NOT EXISTS $_deletedTodosTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_date TEXT NOT NULL,
        deleted_date TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<List<TodoItem>> getTodos() async {
    final database = await _db;
    final maps = await database.query(
      _todosTable,
      orderBy: 'sort_order ASC, id DESC',
    );
    return maps.map(TodoItem.fromMap).toList();
  }

  @override
  Future<TodoItem> addTodo(TodoItem todo) async {
    final database = await _db;
    final id = await database.transaction((transaction) async {
      await transaction.rawUpdate(
        'UPDATE $_todosTable SET sort_order = sort_order + 1',
      );
      return transaction.insert(_todosTable, {
        ...todo.toMap(),
        'sort_order': 0,
      });
    });
    return TodoItem(
      id: id,
      content: todo.content,
      createdDate: todo.createdDate,
    );
  }

  @override
  Future<void> moveTodoToTrash(int id, String deletedDate) async {
    final database = await _db;
    await database.transaction((transaction) async {
      final rows = await transaction.query(
        _todosTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return;

      final todo = rows.single;
      await transaction.insert(_deletedTodosTable, {
        'original_id': todo['id'],
        'content': todo['content'],
        'created_date': todo['created_date'],
        'deleted_date': deletedDate,
      });
      await transaction.delete(_todosTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<List<DeletedTodoItem>> getDeletedTodos() async {
    final database = await _db;
    final maps = await database.query(_deletedTodosTable, orderBy: 'id DESC');
    return maps.map(DeletedTodoItem.fromMap).toList();
  }

  @override
  Future<void> permanentlyDeleteTodo(int id) async {
    final database = await _db;
    await database.delete(_deletedTodosTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> restoreTodo(int id) async {
    final database = await _db;
    await database.transaction((transaction) async {
      final rows = await transaction.query(
        _deletedTodosTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return;

      final deletedTodo = rows.single;
      await transaction.rawUpdate(
        'UPDATE $_todosTable SET sort_order = sort_order + 1',
      );
      await transaction.insert(_todosTable, {
        'content': deletedTodo['content'],
        'created_date': deletedTodo['created_date'],
        'sort_order': 0,
      });
      await transaction.delete(
        _deletedTodosTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> emptyTrash() async {
    final database = await _db;
    await database.delete(_deletedTodosTable);
  }

  @override
  Future<void> updateTodoOrder(List<int> orderedIds) async {
    final database = await _db;
    await database.transaction((transaction) async {
      final batch = transaction.batch();
      for (var index = 0; index < orderedIds.length; index++) {
        batch.update(
          _todosTable,
          {'sort_order': index},
          where: 'id = ?',
          whereArgs: [orderedIds[index]],
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
