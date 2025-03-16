import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseSutOlcumKoyunHelper {
  static final DatabaseSutOlcumKoyunHelper instance = DatabaseSutOlcumKoyunHelper._instance();
  static Database? _db;

  DatabaseSutOlcumKoyunHelper._instance();

  String sutOlcumKoyunTable = 'sutOlcumKoyunTable';
  String colId = 'id';
  String colWeight = 'weight';
  String colType = 'type';
  String colDate = 'date';
  String colTime = 'time';

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
      'CREATE TABLE IF NOT EXISTS $sutOlcumKoyunTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colWeight REAL, $colType TEXT, $colDate TEXT, $colTime TEXT)',
    );
  }

  Future<int> insertSutOlcumKoyun(Map<String, dynamic> sutOlcumKoyun) async {
    Database? db = await this.db;
    final int result = await db!.insert(sutOlcumKoyunTable, sutOlcumKoyun);
    return result;
  }

  Future<List<Map<String, dynamic>>> getSutOlcumKoyun() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(sutOlcumKoyunTable);
    return result;
  }

  Future<int> deleteSutOlcumKoyun(int id) async {
    Database? db = await this.db;
    return await db!.delete(sutOlcumKoyunTable, where: 'id = ?', whereArgs: [id]);
  }
}

