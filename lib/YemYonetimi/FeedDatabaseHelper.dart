import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'FeedModel.dart';

class FeedDatabaseHelper {
  static final FeedDatabaseHelper instance = FeedDatabaseHelper._init();
  static Database? _database;

  FeedDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('feeds.db');
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
    await db.execute('''
      CREATE TABLE feeds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        brand TEXT,
        batchNumber TEXT,
        purchaseDate TEXT NOT NULL,
        expiryDate TEXT,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        currency TEXT NOT NULL,
        animalGroup TEXT NOT NULL,
        feedingTime TEXT,
        notes TEXT,
        storageLocation TEXT NOT NULL,
        minimumStock REAL NOT NULL,
        nutritionalValues TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<Feed> create(Feed feed) async {
    final db = await instance.database;
    final id = await db.insert('feeds', feed.toMap());
    return feed.copyWith(id: id);
  }

  Future<Feed?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'feeds',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Feed.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Feed>> readAll({
    String? type,
    String? animalGroup,
    bool activeOnly = true,
  }) async {
    final db = await instance.database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (type != null) {
      whereConditions.add('type = ?');
      whereArgs.add(type);
    }

    if (animalGroup != null) {
      whereConditions.add('animalGroup = ?');
      whereArgs.add(animalGroup);
    }

    if (activeOnly) {
      whereConditions.add('isActive = 1');
    }

    final String whereClause =
        whereConditions.isEmpty ? '' : 'WHERE ${whereConditions.join(' AND ')}';

    final result = await db.rawQuery(
      'SELECT * FROM feeds $whereClause ORDER BY purchaseDate DESC',
      whereArgs,
    );

    return result.map((json) => Feed.fromMap(json)).toList();
  }

  Future<List<Feed>> getLowStockFeeds() async {
    final db = await instance.database;
    final result = await db.query(
      'feeds',
      where: 'quantity <= minimumStock AND isActive = 1',
    );
    return result.map((json) => Feed.fromMap(json)).toList();
  }

  Future<List<Feed>> getExpiringFeeds({int daysThreshold = 30}) async {
    final db = await instance.database;
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));

    final result = await db.query(
      'feeds',
      where: 'expiryDate IS NOT NULL AND expiryDate <= ? AND isActive = 1',
      whereArgs: [threshold.toIso8601String()],
    );
    return result.map((json) => Feed.fromMap(json)).toList();
  }

  Future<int> update(Feed feed) async {
    final db = await instance.database;
    return db.update(
      'feeds',
      feed.toMap(),
      where: 'id = ?',
      whereArgs: [feed.id],
    );
  }

  Future<int> updateQuantity(int id, double newQuantity) async {
    final db = await instance.database;
    return db.update(
      'feeds',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'feeds',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deactivate(int id) async {
    final db = await instance.database;
    return await db.update(
      'feeds',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getStockSummary() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT type, SUM(quantity) as total
      FROM feeds
      WHERE isActive = 1
      GROUP BY type
    ''');

    return Map.fromEntries(
      result.map((row) => MapEntry(
            row['type'] as String,
            row['total'] as double,
          )),
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
