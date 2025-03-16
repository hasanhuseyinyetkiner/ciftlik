import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseAddAnimalNoteHelper {
  static final DatabaseAddAnimalNoteHelper instance = DatabaseAddAnimalNoteHelper._instance();
  static Database? _db;

  DatabaseAddAnimalNoteHelper._instance();

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
          CREATE TABLE IF NOT EXISTS noteAnimalDetail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagNo TEXT,
            date TEXT,
            notes TEXT
          )
        ''');
      },
    );
    return merlabDb;
  }

  Future<int> addNote(Map<String, dynamic> noteDetails) async {
    Database? db = await this.db;
    return await db!.insert('noteAnimalDetail', noteDetails);
  }

  Future<List<Map<String, dynamic>>> getNotesByTagNo(String tagNo) async {
    Database? db = await this.db;
    return await db!.query(
      'noteAnimalDetail',
      where: 'tagNo = ?',
      whereArgs: [tagNo],
    );
  }

  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'noteAnimalDetail',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
