import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_app/model/students.dart';

class DatabaseHandler {

  // SQLite 초기화
  Future<Database> initializeDB() async{
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'student.db'),
      onCreate: (db, version) async{
        await db.execute(
          "create table students (id integer primary key autoincrement, code text, name text, dept text, phone text)"
        );
      },
      version: 1
    );
  }

  // 입력
  Future<int> insertStudents(Students student) async{
    int result = 0;

    final Database db = await initializeDB();
    result =await db.rawInsert(
      'insert into students (code, name, dept, phone) values (?,?,?,?)',
      [student.code, student.name, student.dept, student.phone]
    );
    return result;
  }

  // 검색
  Future<List<Students>> queryStudents() async{
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery('select * from students');
    return queryResults.map((e) => Students.fromMap(e)).toList();
  }

  // 수정
  Future<int> updateStudents(Students student) async{
    int result = 0;

    final Database db = await initializeDB();
    result =await db.rawUpdate(
      'update students set name = ?, dept = ?, phone = ? where code = ?',
      [student.name, student.dept, student.phone, student.code]
    );
    return result;
  }

  // 삭제
  Future<void> deleteStudents(int id) async{
    final Database db = await initializeDB();
    await db.rawDelete(
      'delete from students where id = ?',
      [id]
    );
  }

}