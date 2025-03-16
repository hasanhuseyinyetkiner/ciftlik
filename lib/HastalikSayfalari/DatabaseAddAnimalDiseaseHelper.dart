import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseAddAnimalDiseaseHelper {
  static final DatabaseAddAnimalDiseaseHelper instance = DatabaseAddAnimalDiseaseHelper._instance();
  static Database? _db;

  DatabaseAddAnimalDiseaseHelper._instance();

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
          CREATE TABLE IF NOT EXISTS diseaseAnimalDetail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagNo TEXT,
            date TEXT,
            diseaseName TEXT,
            notes TEXT
          )
        ''');
      },
    );
    return merlabDb;
  }

  Future<int> addDisease(Map<String, dynamic> diseaseDetails) async {
    Database? db = await this.db;
    return await db!.insert('diseaseAnimalDetail', diseaseDetails);
  }

  Future<List<Map<String, dynamic>>> getDiseasesByTagNo(String tagNo) async {
    Database? db = await this.db;
    return await db!.query(
      'diseaseAnimalDetail',
      where: 'tagNo = ?',
      whereArgs: [tagNo],
    );
  }

  Future<int> deleteDisease(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'diseaseAnimalDetail',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
