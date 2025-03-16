import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService extends GetxService {
  late Database _database;
  final String _databaseName = 'merlab.db';
  final String _animalTypeTableName = 'AnimalType';
  final String _animalSubtypeTableName = 'AnimalSubtype';

  Future<void> initializeDatabase() async {
    String directory = await getDatabasesPath();
    String path = join(directory, _databaseName);
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_animalTypeTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animaltype TEXT,
          typedesc TEXT,
          logo TEXT,
          isactive INTEGER,
          userid INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_animalSubtypeTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subtype TEXT,
          typedesc TEXT,
          logo TEXT,
          isactive INTEGER,
          userid INTEGER
        )
      ''');
    });
  }

  Future<void> addAnimalType(
      Map<String, dynamic> animalData, BuildContext context) async {
    await _database.insert(_animalTypeTableName, animalData);

    // Eklenen veri için başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veri başarıyla eklendi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAnimalTypesFromSQLite() async {
    await initializeDatabase();
    return await _database.query(_animalTypeTableName);
  }

  Future<void> addAnimalSubtype(
      Map<String, dynamic> subtypeData, BuildContext context) async {
    await _database.insert(_animalSubtypeTableName, subtypeData);

    // Eklenen veri için başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Animal subtype data added successfully.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAnimalSubtypesFromSQLite() async {
    await initializeDatabase();
    return await _database.query(_animalSubtypeTableName);
  }

  // Tüm ağırlık raporlarını getir
  Future<List<Map<String, dynamic>>> getAllWeightReports() async {
    final db = await _database;
    return await db.query('weight_reports', orderBy: 'date DESC');
  }

  // Belirli bir hayvanın ağırlık raporlarını getir
  Future<List<Map<String, dynamic>>> getWeightReportsByTagNo(
      String tagNo) async {
    final db = await _database;
    return await db.query(
      'weight_reports',
      where: 'tagNo = ?',
      whereArgs: [tagNo],
      orderBy: 'date DESC',
    );
  }

  // Ağırlık analizi verilerini getir
  Future<List<Map<String, dynamic>>> getWeightAnalysisData(
    int period,
    String group,
    double minWeight,
    double maxWeight,
  ) async {
    final db = await _database;
    String query = '''
      SELECT 
        w.*,
        a.name,
        a.group_name,
        (
          SELECT w2.weight - w1.weight
          FROM weight_reports w1
          JOIN weight_reports w2 ON w1.animal_id = w2.animal_id
          WHERE w2.date = w.date
          AND w1.date = (
            SELECT MAX(date)
            FROM weight_reports
            WHERE animal_id = w.animal_id
            AND date < w.date
          )
        ) as gain,
        (
          SELECT MAX(weight) - MIN(weight)
          FROM weight_reports
          WHERE animal_id = w.animal_id
          AND date >= date('now', '-$period days')
        ) as totalGain
      FROM weight_reports w
      JOIN animals a ON w.animal_id = a.id
      WHERE w.date >= date('now', '-$period days')
    ''';

    List<String> conditions = [];
    List<dynamic> arguments = [];

    if (group.isNotEmpty && group != 'Tüm Gruplar') {
      conditions.add('a.group_name = ?');
      arguments.add(group);
    }

    if (minWeight > 0) {
      conditions.add('w.weight >= ?');
      arguments.add(minWeight);
    }

    if (maxWeight > 0) {
      conditions.add('w.weight <= ?');
      arguments.add(maxWeight);
    }

    if (conditions.isNotEmpty) {
      query += ' AND ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY w.date DESC';

    return await db.rawQuery(query, arguments);
  }

  // Otomatik tartım için veritabanı metodları
  Future<String?> getLastConnectedDeviceId() async {
    final db = await _database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['last_connected_device'],
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  Future<void> saveLastConnectedDeviceId(String deviceId) async {
    final db = await _database;
    await db.insert(
      'settings',
      {'key': 'last_connected_device', 'value': deviceId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveWeightRecord(Map<String, dynamic> record) async {
    final db = await _database;
    await db.insert('auto_weight_records', record);
  }

  Future<List<Map<String, dynamic>>> getSeparationRules() async {
    final db = await _database;
    return await db.query('separation_rules');
  }

  Future<Map<String, dynamic>> getWeightingStats() async {
    final db = await _database;
    final List<Map<String, dynamic>> result =
        await db.query('auto_weight_stats');
    if (result.isEmpty) {
      return {
        'totalWeighings': 0,
        'errorRate': 0.0,
        'lastSync': DateTime.now().toIso8601String(),
      };
    }
    return result.first;
  }

  Future<void> saveWeightingStats(Map<String, Object> stats) async {
    final db = await _database;
    await db.insert(
      'auto_weight_stats',
      {
        'totalWeighings': stats['totalWeighings'],
        'errorRate': stats['errorRate'],
        'lastSync': (stats['lastSync'] as DateTime).toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Otomatik tartım tabloları oluşturma
  Future<void> _createAutoWeightTables(Database db, int version) async {
    // Ayarlar tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Otomatik tartım kayıtları tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS auto_weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        timestamp TEXT NOT NULL,
        category TEXT,
        deviceId TEXT,
        error INTEGER DEFAULT 0
      )
    ''');

    // Ayırma kuralları tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS separation_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        minWeight REAL NOT NULL,
        maxWeight REAL NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // İstatistikler tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS auto_weight_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        totalWeighings INTEGER NOT NULL,
        errorRate REAL NOT NULL,
        lastSync TEXT NOT NULL
      )
    ''');
  }

  Future<void> syncAnimalData(Map<String, dynamic> data) async {
    final db = await _database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('animals');

      // Insert new data
      for (var animal in data['hayvanlar']) {
        await txn.insert('animals', {
          'id': animal['id'],
          'name': animal['name'],
          'type': animal['type'],
          'birth_date': animal['birth_date'],
          'gender': animal['gender'],
          'status': animal['status'],
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> syncHealthRecords(Map<String, dynamic> data) async {
    final db = await _database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('health_records');

      // Insert new data
      for (var record in data['saglik_kayitlari']) {
        await txn.insert('health_records', {
          'id': record['id'],
          'animal_id': record['animal_id'],
          'record_date': record['record_date'],
          'diagnosis': record['diagnosis'],
          'treatment': record['treatment'],
          'notes': record['notes'],
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> syncMilkData(Map<String, dynamic> data) async {
    final db = await _database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('milk_records');

      // Insert new data
      for (var record in data['sut_olcumleri']) {
        await txn.insert('milk_records', {
          'id': record['id'],
          'animal_id': record['animal_id'],
          'measurement_date': record['measurement_date'],
          'quantity': record['quantity'],
          'quality': record['quality'],
          'notes': record['notes'],
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> syncVaccineData(Map<String, dynamic> data) async {
    final db = await _database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('vaccine_records');

      // Insert new data
      for (var record in data['asi_kayitlari']) {
        await txn.insert('vaccine_records', {
          'id': record['id'],
          'animal_id': record['animal_id'],
          'vaccine_date': record['vaccine_date'],
          'vaccine_type': record['vaccine_type'],
          'next_vaccine_date': record['next_vaccine_date'],
          'notes': record['notes'],
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> syncFinanceData(Map<String, dynamic> data) async {
    final db = await _database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('finance_records');

      // Insert new data
      for (var record in data['gelir_gider']) {
        await txn.insert('finance_records', {
          'id': record['id'],
          'type': record['type'],
          'amount': record['amount'],
          'date': record['date'],
          'category': record['category'],
          'description': record['description'],
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> _createTables(Database db, int version) async {
    // Animals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animals (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        birth_date TEXT,
        gender TEXT,
        status TEXT,
        last_updated TEXT
      )
    ''');

    // Health records table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS health_records (
        id INTEGER PRIMARY KEY,
        animal_id INTEGER NOT NULL,
        record_date TEXT NOT NULL,
        diagnosis TEXT,
        treatment TEXT,
        notes TEXT,
        last_updated TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');

    // Milk records table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS milk_records (
        id INTEGER PRIMARY KEY,
        animal_id INTEGER NOT NULL,
        measurement_date TEXT NOT NULL,
        quantity REAL,
        quality TEXT,
        notes TEXT,
        last_updated TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');

    // Vaccine records table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccine_records (
        id INTEGER PRIMARY KEY,
        animal_id INTEGER NOT NULL,
        vaccine_date TEXT NOT NULL,
        vaccine_type TEXT NOT NULL,
        next_vaccine_date TEXT,
        notes TEXT,
        last_updated TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');

    // Finance records table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS finance_records (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT,
        description TEXT,
        last_updated TEXT
      )
    ''');

    // Settings table for app configuration
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Create other necessary tables
    await _createAutoWeightTables(db, version);
  }
}
