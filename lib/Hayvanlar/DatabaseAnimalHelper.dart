import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseAnimalHelper {
  static final DatabaseAnimalHelper instance = DatabaseAnimalHelper._instance();
  static Database? _db;

  DatabaseAnimalHelper._instance();

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
      'CREATE TABLE IF NOT EXISTS koyunTable(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS kocTable(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS inekTable(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS bogaTable(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS lambTable(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS buzagiTable(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS Animal(id INTEGER PRIMARY KEY AUTOINCREMENT, tagNo TEXT, name TEXT, animalsubtypeid INTEGER, FOREIGN KEY(animalsubtypeid) REFERENCES AnimalSubType(id))',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS AnimalSubType(id INTEGER PRIMARY KEY AUTOINCREMENT, animaltypeid INTEGER, name TEXT, FOREIGN KEY(animaltypeid) REFERENCES AnimalType(id))',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS AnimalType(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
    );
  }

  Future<Map<String, dynamic>?> getAnimalByTagNo(String tableName, String tagNo) async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(
      tableName,
      where: 'tagNo = ?',
      whereArgs: [tagNo],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAnimals(String tableName) async {
    Database? db = await this.db;
    return await db!.query(tableName);
  }
  Future<void> updateAnimalWeanedStatus(String tagNo, int weanedStatus) async {
    Database? db = await this.db;
    await db!.update(
      'Animal',  // Animal tablosu
      {'weaned': weanedStatus},  // weaned değerini güncelliyoruz
      where: 'tagNo = ?',  // Hangi hayvanın güncelleneceğini tagNo'ya göre belirliyoruz
      whereArgs: [tagNo],
    );
  }


  Future<void> deleteAnimal(int id, String tableName) async {
    Database? db = await this.db;
    await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
