import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseBuzagiHelper {
  static final DatabaseBuzagiHelper instance = DatabaseBuzagiHelper._instance();
  static Database? _db;

  DatabaseBuzagiHelper._instance();

  String animalTable = 'Animal';
  String colId = 'id';
  String colWeight = 'weight';
  String colMother = 'mother';
  String colFather = 'father';
  String colDob = 'dob';
  String colTime = 'time';
  String colTagNo = 'tagNo';
  String colGovTagNo = 'govTagNo';
  String colSpecies = 'species';
  String colName = 'name';
  String colGender = 'gender';
  String colType = 'type';
  String colAnimalSubTypeId = 'animalsubtypeid'; // Yeni alan
  String colWeaned = 'weaned';

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
      'CREATE TABLE IF NOT EXISTS $animalTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colWeight REAL, $colMother INTEGER, $colFather INTEGER, $colDob TEXT, $colTime TEXT, $colTagNo TEXT, $colGovTagNo TEXT, $colAnimalSubTypeId INTEGER, $colSpecies TEXT, $colName TEXT, $colGender TEXT, $colType TEXT,$colWeaned INTEGER, FOREIGN KEY($colMother) REFERENCES $animalTable($colId), FOREIGN KEY($colFather) REFERENCES $animalTable($colId), FOREIGN KEY($colAnimalSubTypeId) REFERENCES AnimalSubType(id))',
    );
  }

  Future<int> insertBuzagi(Map<String, dynamic> buzagi) async {
    Database? db = await this.db;
    final int result = await db!.insert(animalTable, buzagi);
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
