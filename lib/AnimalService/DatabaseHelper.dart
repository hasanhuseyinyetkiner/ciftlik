import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('merlab_ciftlik.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1);
  }

  Future<int> getAnimalCountByType(List<String> types) async {
    final db = await database;
    int totalCount = 0;

    for (var type in types) {
      var tableName = '${type}Table';
      var result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      totalCount += Sqflite.firstIntValue(result) ?? 0;
    }

    return totalCount;
  }

  Future<List<Map<String, dynamic>>> getAnimalAdditionsByDate(
      String timeRange) async {
    final db = await database;
    var endDate = DateTime.now();
    var startDate = DateTime.now();

    switch (timeRange) {
      case 'Haftalık':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case 'Aylık':
        startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
        break;
      case 'Yıllık':
        startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
        break;
      default:
        startDate = endDate.subtract(const Duration(days: 7));
    }

    var tables = [
      'inekTable',
      'boğaTable',
      'buzağıTable',
      'koyunTable',
      'koçTable',
      'kuzuTable'
    ];
    List<Map<String, dynamic>> result = [];

    for (var date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      var dateStr = date.toString().split(' ')[0];
      int totalCount = 0;

      for (var table in tables) {
        var count = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $table WHERE date(createdAt) = ?',
            [dateStr]);
        totalCount += Sqflite.firstIntValue(count) ?? 0;
      }

      if (totalCount > 0) {
        result.add({
          'date': dateStr,
          'count': totalCount,
        });
      }
    }

    return result;
  }
}
