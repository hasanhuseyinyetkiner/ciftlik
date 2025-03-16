import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseAddPregnancyCheckHelper {
  static final DatabaseAddPregnancyCheckHelper instance = DatabaseAddPregnancyCheckHelper._instance();
  static Database? _db;

  DatabaseAddPregnancyCheckHelper._instance();

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    final merlabDb = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS pregnancyCheckDetail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagNo TEXT,
            date TEXT,
            kontrolSonucu TEXT,
            notes TEXT
          )
        ''');
      },
    );
    return merlabDb;
  }

  Future<int> addKontrol(Map<String, dynamic> kontrolDetails) async {
    Database? db = await this.db;
    return await db!.insert('pregnancyCheckDetail', kontrolDetails);
  }

  Future<List<Map<String, dynamic>>> getKontrolsByTagNo(String tagNo) async {
    Database? db = await this.db;
    return await db!.query(
      'pregnancyCheckDetail',
      where: 'tagNo = ?',
      whereArgs: [tagNo],
    );
  }

  Future<int> deleteKontrol(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'pregnancyCheckDetail',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
