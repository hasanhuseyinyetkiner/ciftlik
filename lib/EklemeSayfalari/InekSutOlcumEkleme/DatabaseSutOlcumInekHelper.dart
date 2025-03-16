import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseSutOlcumInekHelper {
  static final DatabaseSutOlcumInekHelper instance = DatabaseSutOlcumInekHelper._instance();
  static Database? _db;

  DatabaseSutOlcumInekHelper._instance();

  String sutOlcumInekTable = 'sutOlcumInekTable';
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
      'CREATE TABLE IF NOT EXISTS $sutOlcumInekTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colWeight REAL, $colType TEXT, $colDate TEXT, $colTime TEXT)',
    );
  }

  Future<int> insertSutOlcumInek(Map<String, dynamic> sutOlcumInek) async {
    Database? db = await this.db;
    final int result = await db!.insert(sutOlcumInekTable, sutOlcumInek);
    return result;
  }

  Future<List<Map<String, dynamic>>> getSutOlcumInek() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(sutOlcumInekTable);
    return result;
  }

  Future<int> deleteSutOlcumInek(int id) async {
    Database? db = await this.db;
    return await db!.delete(sutOlcumInekTable, where: 'id = ?', whereArgs: [id]);
  }
}
