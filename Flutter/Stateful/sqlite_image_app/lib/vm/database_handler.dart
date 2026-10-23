import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_image_app/model/address.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'address.db'),
      onCreate: (db, version) async {
        await db.execute("""
            create table address
            (
            id integer primary key autoincrement,
            name text,
            phone text,
            address text,
            relation text,
            image blob
            )
          """);
      },
      version: 1,
    );
  }

  Future<int> insertAddress(Address address) async {
    int result = 0;
    Database db = await initializeDB();
    result = await db.rawInsert(
      """
        insert into address
        (name, phone, address, relation, image)
        values
        (?, ?, ?, ?, ?)
      """,
      [
        address.name,
        address.phone,
        address.address,
        address.relation,
        address.image,
      ],
    );
    return result;
  }

  Future<List<Address>> queryAddress() async {
    Database db = await initializeDB();
    List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from address',
    );
    return queryResult.map((e) => Address.fromMap(e)).toList();
  }

  /// 데이터베이스에 저장된 전체 주소 카드 개수를 조회합니다.
  Future<int> countAddress() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> result = await db.rawQuery(
      'select count(*) from address',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 입력한 이름이 포함된 주소록 데이터를 조회합니다.
  Future<List<Address>> searchAddressByName(String name) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      'select * from address where name like ? order by id desc',
      ['%$name%'],
    );
    return queryResult.map((e) => Address.fromMap(e)).toList();
  }

  Future<void> deleteAddress(int id) async {
    final Database db = await initializeDB();
    await db.rawDelete('delete from address where id = ?', [id]);
  }

  Future<int> updateAddress(Address address) async {
    int result = 0;

    final Database db = await initializeDB();
    result = await db.rawUpdate(
      'update address set name = ?, phone = ?, relation = ?, image = ?  where address = ?',
      [
        address.name,
        address.phone,
        address.relation,
        address.image,
        address.address,
      ],
    );
    return result;
  }
}
