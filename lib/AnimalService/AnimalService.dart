import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnimalService {
  static final AnimalService instance = AnimalService._instance();
  static Database? _db;

  AnimalService._instance();

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
  Future<Map<String, dynamic>?> getAnimalDetails(String tableName, int animalId) async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(
      tableName,
      where: 'id = ?',
      whereArgs: [animalId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
  Future<int> updateAnimalDetails(String tableName, int animalId, Map<String, dynamic> updatedDetails) async {
    Database? db = await this.db;
    return await db!.update(
      tableName,
      updatedDetails,
      where: 'id = ?',
      whereArgs: [animalId],
    );
  }

  Future<List<Map<String, dynamic>>> getKoyunList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 1
    ''');
  }

  Future<List<Map<String, dynamic>>> getKocList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo  
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 2
    ''');
  }
  Future<List<Map<String, dynamic>>> getInekList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 3
    ''');
  }
  Future<List<Map<String, dynamic>>> getBogaList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 4
    ''');
  }
  Future<List<Map<String, dynamic>>> getKuzuList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 5
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getBuzagiList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 6
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getKoyunSpeciesList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id, animaltypeid, animalsubtypename
      FROM AnimalSubType
      WHERE animaltypeid = 1
    ''');
  }
  Future<List<Map<String, dynamic>>> getKocSpeciesList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id, animaltypeid, animalsubtypename
      FROM AnimalSubType
      WHERE animaltypeid = 2
    ''');
  }
  Future<List<Map<String, dynamic>>> getInekSpeciesList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id, animaltypeid, animalsubtypename
      FROM AnimalSubType
      WHERE animaltypeid = 3
    ''');
  }
  Future<List<Map<String, dynamic>>> getBogaSpeciesList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id, animaltypeid, animalsubtypename
      FROM AnimalSubType
      WHERE animaltypeid = 4
    ''');
  }
  Future<List<Map<String, dynamic>>> getKuzuSpeciesList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id, animaltypeid, animalsubtypename
      FROM AnimalSubType
      WHERE animaltypeid = 5
    ''');
  }
  Future<List<Map<String, dynamic>>> getBuzagiSpeciesList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id, animaltypeid, animalsubtypename
      FROM AnimalSubType
      WHERE animaltypeid = 6
    ''');
  }
  Future<List<Map<String, dynamic>>> getKoyunAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo,a.dob
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 1
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getKocAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo,a.dob 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 2
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getInekAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo,a.dob
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 3
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getBogaAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo,a.dob 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 4
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getKuzuAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo,a.dob 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 5
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getBuzagiAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT a.id, a.name, a.tagNo,a.dob 
      FROM Animal a
      JOIN AnimalSubType ast ON a.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 6
      AND a.weaned = 0;
    ''');
  }
  Future<List<Map<String, dynamic>>> getWeanedBuzagiAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT w.id, w.name, w.tagNo,w.weaneddate 
      FROM WeanedAnimal w
      JOIN AnimalSubType ast ON w.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 6
      AND w.weaned = 1;
    ''');
  }
  Future<List<Map<String, dynamic>>> getWeanedKuzuAnimalList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT w.id, w.name, w.tagNo,w.weaneddate 
      FROM WeanedAnimal w
      JOIN AnimalSubType ast ON w.animalsubtypeid = ast.id
      WHERE ast.animaltypeid = 5
      AND w.weaned = 1;
    ''');
  }
  Future<List<Map<String, dynamic>>> getVaccineList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id,vaccinename FROM vaccineTable
    ''');
  }
  Future<List<Map<String, dynamic>>> getExaminationList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id,examinationname FROM examinationTable
    ''');
  }
  Future<List<Map<String, dynamic>>> getDiseaseList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id,diseasename FROM diseaseTable
    ''');
  }
  Future<List<Map<String, dynamic>>> getLocationList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT ahir.name AS Ahir_Name, bolme.name AS Bolme_Name
      FROM ahir
      LEFT JOIN bolme ON ahir.id = bolme.ahirId;
    ''');
  }
  Future<List<Map<String, dynamic>>> getGroupList() async {
    Database? db = await this.db;
    return await db!.rawQuery('''
      SELECT id,groupname FROM groupTable
    ''');
  }
}
