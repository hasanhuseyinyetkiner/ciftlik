import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseDiseaseHelper {
  static final DatabaseDiseaseHelper instance = DatabaseDiseaseHelper._instance();
  static Database? _db;

  DatabaseDiseaseHelper._instance();

  String diseaseTable = 'DiseaseTable';
  String colId = 'id';
  String colDiseaseName = 'diseaseName';
  String colDiseaseDescription = 'diseaseDescription';

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
      'CREATE TABLE IF NOT EXISTS $diseaseTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDiseaseName TEXT, $colDiseaseDescription TEXT)',
    );
  }

  Future<int> insertDisease(Map<String, dynamic> disease) async {
    Database? db = await this.db;
    final int result = await db!.insert(diseaseTable, disease);
    return result;
  }

  Future<List<Map<String, dynamic>>> getDiseases() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(diseaseTable);
    return result;
  }

  Future<int> deleteDisease(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(diseaseTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }
}
