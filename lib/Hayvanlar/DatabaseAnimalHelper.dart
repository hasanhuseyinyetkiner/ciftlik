import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../database/database_config.dart';

class DatabaseAnimalHelper {
  static final DatabaseAnimalHelper instance = DatabaseAnimalHelper._init();
  static Database? _database;

  DatabaseAnimalHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('farm_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create tables if they don't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS koyunTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS kocTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inekTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bogaTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lambTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS buzagiTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Animal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT,
        name TEXT,
        dob TEXT,
        date TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAnimals(String tableName) async {
    final db = await instance.database;
    try {
      return await db.query(tableName);
    } catch (e) {
      print('Error getting animals from $tableName: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAnimalByTagNo(String tableName, String tagNo) async {
    final db = await instance.database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        tableName,
        where: 'tagNo = ?',
        whereArgs: [tagNo],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting animal by tag number from $tableName: $e');
      return null;
    }
  }

  Future<int> deleteAnimal(int id, String tableName) async {
    final db = await instance.database;
    try {
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting animal from $tableName: $e');
      return 0;
    }
  }

  Future<int> insertAnimal(String tableName, Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      return await db.insert(tableName, data);
    } catch (e) {
      print('Error inserting animal into $tableName: $e');
      return -1;
    }
  }

  Future<int> updateAnimalDetails(String tableName, int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      return await db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating animal in $tableName: $e');
      return 0;
    }
  }
}
