import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_codex_app/model/student.dart';

class StudentDatabase {
  StudentDatabase._();

  static final StudentDatabase instance = StudentDatabase._();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = join(await getDatabasesPath(), 'students.db');
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) {
        return database.execute(
          'CREATE TABLE students('
          'code TEXT PRIMARY KEY, '
          'name TEXT NOT NULL, '
          'department TEXT NOT NULL, '
          'phone TEXT NOT NULL'
          ')',
        );
      },
    );
  }

  Future<List<Student>> readStudents() async {
    final database = await this.database;
    final maps = await database.query('students', orderBy: 'code ASC');
    return maps.map(Student.fromMap).toList();
  }

  Future<void> insertStudent(Student student) async {
    final database = await this.database;
    await database.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateStudent(Student student) async {
    final database = await this.database;
    await database.update(
      'students',
      student.toMap(),
      where: 'code = ?',
      whereArgs: [student.code],
    );
  }

  Future<void> deleteStudent(String code) async {
    final database = await this.database;
    await database.delete('students', where: 'code = ?', whereArgs: [code]);
  }
}
