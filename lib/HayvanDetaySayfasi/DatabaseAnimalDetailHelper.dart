import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseAnimalDetailHelper {
  static final DatabaseAnimalDetailHelper instance = DatabaseAnimalDetailHelper._instance();
  static Database? _db;

  DatabaseAnimalDetailHelper._instance();

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    final merlabDb = await openDatabase(
      path,
      version: 1,
    );
    return merlabDb;
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
}
