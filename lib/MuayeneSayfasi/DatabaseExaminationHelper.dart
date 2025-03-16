import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'ExaminationModel.dart';

class DatabaseExaminationHelper {
  static final DatabaseExaminationHelper instance =
      DatabaseExaminationHelper._init();
  static Database? _database;

  DatabaseExaminationHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('merlab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS examinations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hayvanId INTEGER NOT NULL,
      vetId INTEGER,
      date TEXT NOT NULL,
      diagnosisCode TEXT,
      diagnosisName TEXT,
      notes TEXT,
      status TEXT,
      treatmentPlans TEXT,
      followUpDate TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
    ''');
  }

  Future<List<Examination>> getExaminations() async {
    final db = await instance.database;
    final result = await db.query('examinations', orderBy: 'date DESC');
    return result.map((json) => Examination.fromJson(json)).toList();
  }

  Future<List<Examination>> getExaminationsByHayvanId(int hayvanId) async {
    final db = await instance.database;
    final result = await db.query('examinations',
        where: 'hayvanId = ?', whereArgs: [hayvanId], orderBy: 'date DESC');
    return result.map((json) => Examination.fromJson(json)).toList();
  }

  Future<int> insertExamination(Examination examination) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    final Map<String, dynamic> data = examination.toJson();
    data['createdAt'] = now;
    data['updatedAt'] = now;

    return await db.insert('examinations', data);
  }

  Future<int> updateExamination(Examination examination) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    final Map<String, dynamic> data = examination.toJson();
    data['updatedAt'] = now;

    return await db.update('examinations', data,
        where: 'id = ?', whereArgs: [examination.id]);
  }

  Future<int> deleteExamination(int id) async {
    final db = await instance.database;
    return await db.delete('examinations', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
