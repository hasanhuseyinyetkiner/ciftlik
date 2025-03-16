import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseKocKatimHelper {
  static final DatabaseKocKatimHelper instance = DatabaseKocKatimHelper._instance();
  static Database? _db;

  DatabaseKocKatimHelper._instance();

  String kocKatimTable = 'kocKatimTable';
  String colId = 'id';
  String colKoyun = 'koyunKupeNo';
  String colKoyunAdi = 'koyunAdi'; // Yeni sütun: Koyun Adı
  String colKoc = 'kocKupeNo';
  String colKocAdi = 'kocAdi';     // Yeni sütun: Koç Adı
  String colDate = 'katimTarihi';
  String colTime = 'katimSaati';

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    final merlabDb = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return merlabDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $kocKatimTable('
          '$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
          '$colKoyun TEXT, '
          '$colKoyunAdi TEXT, '  // Koyun Adı sütunu
          '$colKoc TEXT, '
          '$colKocAdi TEXT, '    // Koç Adı sütunu
          '$colDate TEXT, '
          '$colTime TEXT)',
    );
  }

  Future<int> insertKocKatim(Map<String, dynamic> kocKatim) async {
    Database? db = await this.db;
    final int result = await db!.insert(kocKatimTable, kocKatim);
    return result;
  }

  Future<bool> isKocKoyunPairExists(String koyunKupeNo, String kocKupeNo) async {
    final db = await instance.db;
    final List<Map<String, dynamic>> result = await db!.query(
      'kocKatimTable',
      where: 'koyunKupeNo = ? AND kocKupeNo = ?',
      whereArgs: [koyunKupeNo, kocKupeNo],
    );

    return result.isNotEmpty;
  }
}
