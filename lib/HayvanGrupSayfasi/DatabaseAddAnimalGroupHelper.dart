import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseAddAnimalGroupHelper {
  static final DatabaseAddAnimalGroupHelper instance = DatabaseAddAnimalGroupHelper._instance();
  static Database? _db;

  DatabaseAddAnimalGroupHelper._instance();

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
          CREATE TABLE IF NOT EXISTS animalGroupDetail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagNo TEXT,
            groupName TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS groupTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            groupName TEXT
          )
        ''');
      },
    );
    return merlabDb;
  }

  Future<int> addGroup(Map<String, dynamic> groupDetails) async {
    Database? db = await this.db;
    return await db!.insert('animalGroupDetail', groupDetails);
  }

  Future<int> addGroupToGroupTable(Map<String, dynamic> groupDetails) async {
    Database? db = await this.db;
    return await db!.insert('groupTable', groupDetails);
  }

  Future<List<Map<String, dynamic>>> getGroupsByTagNo(String tagNo) async {
    Database? db = await this.db;
    return await db!.query(
      'animalGroupDetail',
      where: 'tagNo = ?',
      whereArgs: [tagNo],
    );
  }

  Future<int> deleteGroup(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'animalGroupDetail',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> removeGroup(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'groupTable',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    Database? db = await this.db;
    return await db!.query('groupTable');
  }
}
