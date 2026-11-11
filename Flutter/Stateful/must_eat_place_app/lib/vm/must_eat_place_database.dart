import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../model/must_eat_place.dart';
import '../model/app_preferences.dart';
import '../model/app_backup.dart';

/// ViewModel이 사용하는 맛집 데이터 CRUD 계약이다.
abstract interface class MustEatPlaceDataSource {
  Future<List<MustEatPlace>> findAll();

  Future<void> insert(MustEatPlace place);

  Future<void> update(MustEatPlace place);

  Future<void> delete(int seq);

  Future<List<String>> findCategories();

  Future<void> insertCategory(String name);

  Future<void> deleteCategory(String name);
}

/// 앱의 화면 설정을 읽고 저장하는 계약이다.
abstract interface class AppSettingsDataSource {
  Future<AppPreferences> findPreferences();

  Future<void> saveDarkMode(bool enabled);

  Future<void> saveThemeColor(AppThemeColor color);
}

/// 전체 사용자 데이터를 JSON 스냅샷으로 내보내고 복원하는 계약이다.
abstract interface class BackupDataSource {
  Future<AppBackup> createBackup();

  Future<void> restoreBackup(AppBackup backup);
}

/// musteatplace 테이블 생성과 SQLite CRUD를 관리한다.
class MustEatPlaceDatabase
    implements MustEatPlaceDataSource, AppSettingsDataSource, BackupDataSource {
  MustEatPlaceDatabase._();

  /// 앱 전체에서 같은 SQLite 연결을 공유하는 단일 인스턴스다.
  static final MustEatPlaceDatabase instance = MustEatPlaceDatabase._();

  /// 모든 SQL에서 공통으로 사용하는 테이블 이름이다.
  static const String tableName = 'musteatplace';

  /// 사용자가 관리하는 카테고리 이름과 표시 순서를 저장하는 테이블이다.
  static const String categoriesTable = 'categories';

  /// 다크모드와 포인트 색상처럼 한 개씩 존재하는 설정을 저장한다.
  static const String settingsTable = 'app_settings';

  /// 한 번 연 SQLite 연결을 보관하며 첫 접근 전에는 null이다.
  Database? _database;

  /// 처음 요청될 때 DB를 열고 이후 같은 연결을 재사용한다.
  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(databasePath, 'must_eat_place.db'),
      version: 9,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            seq INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            phone TEXT NOT NULL,
            lat REAL NOT NULL,
            lng REAL NOT NULL,
            image BLOB,
            estimate TEXT NOT NULL DEFAULT '',
            initdate TEXT NOT NULL,
            favorite INTEGER NOT NULL DEFAULT 0,
            menu TEXT NOT NULL DEFAULT '',
            rating REAL NOT NULL DEFAULT 0,
            address TEXT NOT NULL DEFAULT ''
          )
        ''');
        await _createCategoriesTable(db);
        await _insertDefaultCategories(db);
        await _createSettingsTable(db);
        await _insertSamplePlaces(db);
        await _insertSampleRatings(db);
        await _insertSampleAddresses(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE $tableName "
            "ADD COLUMN category TEXT NOT NULL DEFAULT '한식'",
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE $tableName '
            'ADD COLUMN favorite INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE $tableName "
            "ADD COLUMN menu TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 5) {
          await _createCategoriesTable(db);
          await _insertDefaultCategories(db);
          await db.execute('''
            INSERT OR IGNORE INTO $categoriesTable(name, sort_order)
            SELECT DISTINCT category, 100
            FROM $tableName
            WHERE category <> ''
          ''');
        }
        if (oldVersion < 6) {
          await _createSettingsTable(db);
        }
        if (oldVersion < 8) {
          await db.execute(
            'ALTER TABLE $tableName '
            'ADD COLUMN rating REAL NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 9) {
          await db.execute(
            "ALTER TABLE $tableName "
            "ADD COLUMN address TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 7) {
          await _insertDefaultCategories(db);
          await _insertSamplePlaces(db);
        }
        if (oldVersion < 8) {
          await _insertSampleRatings(db);
        }
        if (oldVersion < 9) {
          await _insertSampleAddresses(db);
        }
      },
    );
    return _database!;
  }

  /// 저장된 화면 설정을 읽고 누락된 값에는 기본값을 적용한다.
  @override
  Future<AppPreferences> findPreferences() async {
    final db = await database;
    final rows = await db.query(settingsTable);
    final values = {
      for (final row in rows)
        row['setting_key'] as String: row['value'] as String,
    };
    return AppPreferences(
      isDarkMode: values['dark_mode'] == '1',
      themeColor: AppThemeColor.fromName(values['theme_color']),
    );
  }

  /// 선택한 다크모드 상태를 한 개의 설정값으로 갱신한다.
  @override
  Future<void> saveDarkMode(bool enabled) =>
      _saveSetting('dark_mode', enabled ? '1' : '0');

  /// 선택한 포인트 색상의 enum 이름을 저장한다.
  @override
  Future<void> saveThemeColor(AppThemeColor color) =>
      _saveSetting('theme_color', color.name);

  Future<void> _saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(settingsTable, {
      'setting_key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 현재 SQLite의 맛집, 카테고리, 화면 설정을 한 시점의 백업으로 만든다.
  @override
  Future<AppBackup> createBackup() async {
    return AppBackup(
      places: await findAll(),
      categories: await findCategories(),
      preferences: await findPreferences(),
      createdAt: DateTime.now(),
    );
  }

  /// 검증된 백업으로 기존 사용자 데이터를 트랜잭션 안에서 전부 교체한다.
  @override
  Future<void> restoreBackup(AppBackup backup) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableName);
      await txn.delete(categoriesTable);
      await txn.delete(settingsTable);

      final categories = List<String>.of(backup.categories);
      for (final place in backup.places) {
        if (!categories.contains(place.category)) {
          categories.add(place.category);
        }
      }
      for (var index = 0; index < categories.length; index++) {
        await txn.insert(categoriesTable, {
          'name': categories[index],
          'sort_order': index,
        });
      }
      for (final place in backup.places) {
        await txn.insert(tableName, place.toMap());
      }
      await txn.insert(settingsTable, {
        'setting_key': 'dark_mode',
        'value': backup.preferences.isDarkMode ? '1' : '0',
      });
      await txn.insert(settingsTable, {
        'setting_key': 'theme_color',
        'value': backup.preferences.themeColor.name,
      });
    });
  }

  /// 최신 등록 항목이 먼저 보이도록 모든 맛집을 조회한다.
  @override
  Future<List<MustEatPlace>> findAll() async {
    final db = await database;
    final rows = await db.query(tableName, orderBy: 'seq DESC');
    return rows.map(MustEatPlace.fromMap).toList();
  }

  /// 새 맛집을 SQLite 행으로 변환해 추가한다.
  @override
  Future<void> insert(MustEatPlace place) async {
    final db = await database;
    await db.insert(tableName, place.toMap());
  }

  /// 모델의 seq를 기준으로 기존 SQLite 행을 갱신한다.
  @override
  Future<void> update(MustEatPlace place) async {
    final db = await database;
    await db.update(
      tableName,
      place.toMap(),
      where: 'seq = ?',
      whereArgs: [place.seq],
    );
  }

  /// seq가 일치하는 SQLite 행 한 건을 삭제한다.
  @override
  Future<void> delete(int seq) async {
    final db = await database;
    await db.delete(tableName, where: 'seq = ?', whereArgs: [seq]);
  }

  /// 설정과 TabBar에 표시할 카테고리를 사용자 지정 순서로 조회한다.
  @override
  Future<List<String>> findCategories() async {
    final db = await database;
    final rows = await db.query(
      categoriesTable,
      columns: ['name'],
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map((row) => row['name'] as String).toList();
  }

  /// 중복되지 않는 새 카테고리를 마지막 순서에 추가한다.
  @override
  Future<void> insertCategory(String name) async {
    final db = await database;
    final maxResult = await db.rawQuery(
      'SELECT MAX(sort_order) FROM $categoriesTable',
    );
    final nextOrder = (Sqflite.firstIntValue(maxResult) ?? -1) + 1;
    await db.insert(categoriesTable, {'name': name, 'sort_order': nextOrder});
  }

  /// 맛집이 사용하지 않는 카테고리만 삭제한다.
  @override
  Future<void> deleteCategory(String name) async {
    final db = await database;
    await db.transaction((txn) async {
      final categoryCount = Sqflite.firstIntValue(
        await txn.rawQuery('SELECT COUNT(*) FROM $categoriesTable'),
      );
      if ((categoryCount ?? 0) <= 1) {
        throw StateError('카테고리는 최소 1개 이상 필요합니다.');
      }

      final placeCount = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM $tableName WHERE category = ?',
          [name],
        ),
      );
      if ((placeCount ?? 0) > 0) {
        throw StateError('사용 중인 카테고리는 삭제할 수 없습니다.');
      }
      await txn.delete(categoriesTable, where: 'name = ?', whereArgs: [name]);
    });
  }

  /// 카테고리 테이블을 최초 생성하거나 마이그레이션 중 보장한다.
  static Future<void> _createCategoriesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $categoriesTable (
        name TEXT PRIMARY KEY,
        sort_order INTEGER NOT NULL
      )
    ''');
  }

  /// 새 DB와 기존 DB 모두에 기본 음식 분류를 중복 없이 채운다.
  static Future<void> _insertDefaultCategories(DatabaseExecutor db) async {
    for (var index = 0; index < MustEatPlace.categories.length; index++) {
      await db.insert(categoriesTable, {
        'name': MustEatPlace.categories[index],
        'sort_order': index,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  /// 키마다 하나의 값만 갖는 사용자 설정 테이블을 보장한다.
  static Future<void> _createSettingsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $settingsTable (
        setting_key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// 연습용 화면이 비어 있지 않도록 네 카테고리의 샘플 맛집을 한 번씩 추가한다.
  static Future<void> _insertSamplePlaces(DatabaseExecutor db) async {
    for (final place in _samplePlaces()) {
      final existing = await db.query(
        tableName,
        columns: ['seq'],
        where: 'name = ?',
        whereArgs: [place.name],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert(tableName, place.toMap());
      }
    }
  }

  /// 서울의 여러 지역을 기준으로 구성한 화면 확인용 임시 데이터다.
  static List<MustEatPlace> _samplePlaces() => [
    MustEatPlace(
      name: '정담 한상',
      category: '한식',
      phone: '02-735-2410',
      lat: 37.5721,
      lng: 126.9854,
      estimate: '정갈한 반찬과 따뜻한 솥밥이 만족스러워요.',
      initDate: DateTime(2026, 8, 1),
      menu: '제육 솥밥 13,000원 · 고등어구이 정식 15,000원',
      isFavorite: true,
    ),
    MustEatPlace(
      name: '마루골 설렁탕',
      category: '한식',
      phone: '02-755-8932',
      lat: 37.5658,
      lng: 126.9772,
      estimate: '국물이 담백하고 고기가 넉넉해서 든든해요.',
      initDate: DateTime(2026, 8, 2),
      menu: '설렁탕 12,000원 · 수육 소 28,000원',
    ),
    MustEatPlace(
      name: '연희 골목김치찜',
      category: '한식',
      phone: '02-336-7104',
      lat: 37.5689,
      lng: 126.9296,
      estimate: '푹 익은 김치와 부드러운 돼지고기의 조합이 좋아요.',
      initDate: DateTime(2026, 8, 3),
      menu: '돼지 김치찜 2인 26,000원 · 계란말이 9,000원',
    ),
    MustEatPlace(
      name: '성수 들깨수제비',
      category: '한식',
      phone: '02-462-5581',
      lat: 37.5447,
      lng: 127.0558,
      estimate: '들깨 향이 진하고 수제비가 쫄깃해요.',
      initDate: DateTime(2026, 8, 4),
      menu: '들깨수제비 10,000원 · 감자전 12,000원',
    ),
    MustEatPlace(
      name: '남산 숯불갈비',
      category: '한식',
      phone: '02-794-6207',
      lat: 37.5346,
      lng: 126.9946,
      estimate: '숯불 향이 좋고 양념이 과하지 않아 맛있어요.',
      initDate: DateTime(2026, 8, 5),
      menu: '돼지갈비 1인분 18,000원 · 물냉면 9,000원',
      isFavorite: true,
    ),
    MustEatPlace(
      name: '홍등각',
      category: '중식',
      phone: '02-736-8421',
      lat: 37.5743,
      lng: 126.9817,
      estimate: '불향 가득한 볶음밥과 바삭한 탕수육이 좋아요.',
      initDate: DateTime(2026, 8, 6),
      menu: '삼선볶음밥 11,000원 · 찹쌀탕수육 소 22,000원',
    ),
    MustEatPlace(
      name: '마라소담',
      category: '중식',
      phone: '02-322-1956',
      lat: 37.5562,
      lng: 126.9238,
      estimate: '재료가 신선하고 맵기를 고를 수 있어 편해요.',
      initDate: DateTime(2026, 8, 7),
      menu: '마라탕 100g 2,200원 · 꿔바로우 18,000원',
      isFavorite: true,
    ),
    MustEatPlace(
      name: '청연 딤섬하우스',
      category: '중식',
      phone: '02-518-3772',
      lat: 37.5248,
      lng: 127.0391,
      estimate: '딤섬피가 얇고 속이 촉촉해서 부담 없이 즐기기 좋아요.',
      initDate: DateTime(2026, 8, 8),
      menu: '하가우 8,500원 · 샤오롱바오 9,000원 · 완탕면 12,000원',
    ),
    MustEatPlace(
      name: '대림 향미면관',
      category: '중식',
      phone: '02-832-4068',
      lat: 37.4934,
      lng: 126.8957,
      estimate: '진한 육수와 쫄깃한 면이 인상적인 우육면집이에요.',
      initDate: DateTime(2026, 8, 9),
      menu: '홍소우육면 11,000원 · 군만두 7,000원',
    ),
    MustEatPlace(
      name: '서촌 금룡반점',
      category: '중식',
      phone: '02-720-6635',
      lat: 37.5792,
      lng: 126.9692,
      estimate: '옛날식 간짜장이 고소하고 양도 넉넉해요.',
      initDate: DateTime(2026, 8, 10),
      menu: '간짜장 9,000원 · 해물짬뽕 11,000원',
    ),
    MustEatPlace(
      name: '스시 하루',
      category: '일식',
      phone: '02-548-1258',
      lat: 37.5219,
      lng: 127.0276,
      estimate: '초밥 밥의 간이 적당하고 생선이 신선해요.',
      initDate: DateTime(2026, 8, 11),
      menu: '오늘의 초밥 12pcs 24,000원 · 사케동 16,000원',
      isFavorite: true,
    ),
    MustEatPlace(
      name: '망원 우동공방',
      category: '일식',
      phone: '02-335-9084',
      lat: 37.5567,
      lng: 126.9015,
      estimate: '면이 탱글하고 국물이 깔끔해서 자주 생각나요.',
      initDate: DateTime(2026, 8, 12),
      menu: '붓카케우동 10,000원 · 새우튀김우동 12,000원',
    ),
    MustEatPlace(
      name: '키츠네 돈카츠',
      category: '일식',
      phone: '02-467-3319',
      lat: 37.5431,
      lng: 127.0704,
      estimate: '튀김옷이 가볍고 고기가 촉촉한 돈카츠예요.',
      initDate: DateTime(2026, 8, 13),
      menu: '로스카츠 정식 14,000원 · 히레카츠 정식 16,000원',
    ),
    MustEatPlace(
      name: '연남 소바정원',
      category: '일식',
      phone: '02-3144-7820',
      lat: 37.5628,
      lng: 126.9251,
      estimate: '메밀 향이 은은하고 곁들임 튀김도 바삭해요.',
      initDate: DateTime(2026, 8, 14),
      menu: '판메밀 11,000원 · 냉소바와 새우튀김 15,000원',
    ),
    MustEatPlace(
      name: '이자카야 달빛',
      category: '일식',
      phone: '02-711-5294',
      lat: 37.5512,
      lng: 126.9568,
      estimate: '조용한 분위기에서 꼬치와 사시미를 즐기기 좋아요.',
      initDate: DateTime(2026, 8, 15),
      menu: '모둠꼬치 18,000원 · 오늘의 사시미 29,000원',
    ),
    MustEatPlace(
      name: '오브제 파스타',
      category: '양식',
      phone: '02-3445-6021',
      lat: 37.5197,
      lng: 127.0234,
      estimate: '소스가 진하지만 느끼하지 않고 분위기도 편안해요.',
      initDate: DateTime(2026, 8, 16),
      menu: '트러플 크림파스타 19,000원 · 라구파스타 18,000원',
      isFavorite: true,
    ),
    MustEatPlace(
      name: '브릭하우스 버거',
      category: '양식',
      phone: '02-797-4438',
      lat: 37.5341,
      lng: 126.9901,
      estimate: '육즙이 풍부한 패티와 담백한 번의 균형이 좋아요.',
      initDate: DateTime(2026, 8, 17),
      menu: '브릭 치즈버거 13,500원 · 칠리프라이 7,000원',
    ),
    MustEatPlace(
      name: '성수 화덕키친',
      category: '양식',
      phone: '02-499-8716',
      lat: 37.5456,
      lng: 127.0527,
      estimate: '쫄깃한 도우와 향긋한 바질 향이 잘 어울려요.',
      initDate: DateTime(2026, 8, 18),
      menu: '마르게리타 피자 18,000원 · 루꼴라 피자 21,000원',
    ),
    MustEatPlace(
      name: '테이블 온',
      category: '양식',
      phone: '02-323-7745',
      lat: 37.5548,
      lng: 126.9298,
      estimate: '브런치 구성이 알차고 채소가 신선해요.',
      initDate: DateTime(2026, 8, 19),
      menu: '에그 베네딕트 16,000원 · 프렌치토스트 15,000원',
    ),
    MustEatPlace(
      name: '한강 스테이크룸',
      category: '양식',
      phone: '02-784-9153',
      lat: 37.5253,
      lng: 126.9258,
      estimate: '굽기가 정확하고 사이드 메뉴까지 완성도가 높아요.',
      initDate: DateTime(2026, 8, 20),
      menu: '채끝 스테이크 200g 36,000원 · 구운 채소 8,000원',
    ),
  ];

  /// 샘플 맛집마다 서로 다른 별점을 적용해 목록과 상세 화면을 확인할 수 있게 한다.
  static Future<void> _insertSampleRatings(DatabaseExecutor db) async {
    const ratings = <String, double>{
      '정담 한상': 4.5,
      '마루골 설렁탕': 4.0,
      '연희 골목김치찜': 4.5,
      '성수 들깨수제비': 4.0,
      '남산 숯불갈비': 5.0,
      '홍등각': 4.0,
      '마라소담': 4.5,
      '청연 딤섬하우스': 4.5,
      '대림 향미면관': 4.0,
      '서촌 금룡반점': 4.5,
      '스시 하루': 5.0,
      '망원 우동공방': 4.5,
      '키츠네 돈카츠': 4.5,
      '연남 소바정원': 4.5,
      '이자카야 달빛': 4.0,
      '오브제 파스타': 5.0,
      '브릭하우스 버거': 4.5,
      '성수 화덕키친': 4.5,
      '테이블 온': 4.0,
      '한강 스테이크룸': 4.5,
    };
    for (final entry in ratings.entries) {
      await db.update(
        tableName,
        {'rating': entry.value},
        where: 'name = ? AND rating = 0',
        whereArgs: [entry.key],
      );
    }
  }

  /// 기존 샘플 맛집에도 상세 화면에서 확인할 수 있는 주소를 채운다.
  static Future<void> _insertSampleAddresses(DatabaseExecutor db) async {
    const addresses = <String, String>{
      '정담 한상': '서울특별시 종로구 인사동길 24',
      '마루골 설렁탕': '서울특별시 중구 세종대로 18길 12',
      '연희 골목김치찜': '서울특별시 서대문구 연희맛로 17',
      '성수 들깨수제비': '서울특별시 성동구 연무장길 33',
      '남산 숯불갈비': '서울특별시 용산구 녹사평대로 40길 21',
      '홍등각': '서울특별시 종로구 삼일대로 32길 18',
      '마라소담': '서울특별시 마포구 어울마당로 112',
      '청연 딤섬하우스': '서울특별시 강남구 도산대로 45길 16',
      '대림 향미면관': '서울특별시 영등포구 도림로 38길 9',
      '서촌 금룡반점': '서울특별시 종로구 자하문로 7길 25',
      '스시 하루': '서울특별시 강남구 압구정로 28길 14',
      '망원 우동공방': '서울특별시 마포구 포은로 8길 20',
      '키츠네 돈카츠': '서울특별시 광진구 아차산로 33길 17',
      '연남 소바정원': '서울특별시 마포구 동교로 38길 27',
      '이자카야 달빛': '서울특별시 마포구 마포대로 12길 18',
      '오브제 파스타': '서울특별시 강남구 도산대로 25길 31',
      '브릭하우스 버거': '서울특별시 용산구 이태원로 20길 15',
      '성수 화덕키친': '서울특별시 성동구 성수이로 12길 11',
      '테이블 온': '서울특별시 마포구 와우산로 29길 14',
      '한강 스테이크룸': '서울특별시 영등포구 여의대로 24',
    };
    for (final entry in addresses.entries) {
      await db.update(
        tableName,
        {'address': entry.value},
        where: "name = ? AND address = ''",
        whereArgs: [entry.key],
      );
    }
  }
}
