import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseKoyunHelper {
  static final DatabaseKoyunHelper instance = DatabaseKoyunHelper._instance();
  static Database? _db;

  DatabaseKoyunHelper._instance();

  String animalTable = 'Animal';
  String colId = 'id';
  String colWeight = 'weight';
  String colTagNo = 'tagNo';
  String colGovTagNo = 'govTagNo';
  String colSpecies = 'species';
  String colName = 'name';
  String colType = 'type';
  String colDob = 'dob';
  String colTime = 'time';
  String colWeaned = 'weaned';
  String colAnimalSubTypeId = 'animalsubtypeid'; // Yeni alan

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
      'CREATE TABLE IF NOT EXISTS $animalTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colWeight REAL, $colTagNo TEXT, $colGovTagNo TEXT, $colSpecies TEXT, $colName TEXT, $colType TEXT,$colWeaned INTEGER, $colDob TEXT, $colTime TEXT, $colAnimalSubTypeId INTEGER, FOREIGN KEY($colAnimalSubTypeId) REFERENCES AnimalSubType(id))',
    );
  }

  Future<int> insertKoyun(Map<String, dynamic> koyun) async {
    Database? db = await this.db;
    final int result = await db!.insert(animalTable, koyun);
    return result;
  }
  Future<bool> isAnimalExists(String tagNo) async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(
      animalTable,
      where: '$colTagNo = ?',
      whereArgs: [tagNo],
    );
    return result.isNotEmpty;
  }
}
