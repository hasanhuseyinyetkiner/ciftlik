import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'AsiModeli.dart';

class AsiVeritabaniYardimcisi {
  static final AsiVeritabaniYardimcisi instance = AsiVeritabaniYardimcisi._init();
  static Database? _database;

  AsiVeritabaniYardimcisi._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('merlab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create table for vaccine types
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vaccineName TEXT NOT NULL,
        vaccineDescription TEXT
      )
    ''');

    // Create table for animal-specific simple vaccinations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccineAnimalDetail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNo TEXT NOT NULL,
        date TEXT NOT NULL,
        vaccineName TEXT,
        notes TEXT
      )
    ''');

    // Create table for detailed vaccination applications
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kupeNo TEXT NOT NULL,
        hayvanTuru TEXT NOT NULL,
        hayvanIrki TEXT NOT NULL,
        asiTuru TEXT NOT NULL,
        asiMarkasi TEXT NOT NULL,
        seriNo TEXT NOT NULL,
        doz REAL NOT NULL,
        dozBirimi TEXT NOT NULL,
        uygulamaYolu TEXT NOT NULL,
        asiTarihi TEXT NOT NULL,
        sonrakiAsiTarihi TEXT,
        veterinerHekim TEXT NOT NULL,
        uygulamaBolgesi TEXT NOT NULL,
        yanEtkiler TEXT,
        notlar TEXT,
        tamamlandi INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Create table for vaccine scheduling
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccineScheduleTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        time TEXT,
        notes TEXT,
        vaccine TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Add any needed database migrations here if schema changes in future
    }
  }

  // Vaccine Type Methods
  Future<int> addVaccineType(Asi asi) async {
    final db = await instance.database;
    return await db.insert('vaccines', asi.toMap());
  }

  Future<List<Asi>> getVaccineTypes() async {
    final db = await instance.database;
    final result = await db.query('vaccines', orderBy: 'vaccineName');
    return result.map((json) => Asi.fromMap(json)).toList();
  }

  Future<int> updateVaccineType(Asi asi) async {
    final db = await instance.database;
    return db.update(
      'vaccines',
      asi.toMap(),
      where: 'id = ?',
      whereArgs: [asi.id],
    );
  }

  Future<int> deleteVaccineType(int id) async {
    final db = await instance.database;
    return await db.delete(
      'vaccines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Animal-Specific Simple Vaccination Methods
  Future<int> addAnimalVaccine(HayvanAsi hayvanAsi) async {
    final db = await instance.database;
    return await db.insert('vaccineAnimalDetail', hayvanAsi.toMap());
  }

  Future<List<HayvanAsi>> getAnimalVaccines(String kupeNo) async {
    final db = await instance.database;
    final result = await db.query(
      'vaccineAnimalDetail',
      where: 'tagNo = ?',
      whereArgs: [kupeNo],
      orderBy: 'date DESC',
    );
    return result.map((json) => HayvanAsi.fromMap(json)).toList();
  }

  Future<int> deleteAnimalVaccine(int id) async {
    final db = await instance.database;
    return await db.delete(
      'vaccineAnimalDetail',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Detailed Vaccination Application Methods
  Future<int> addVaccinationApplication(AsiUygulamasi asiUygulamasi) async {
    final db = await instance.database;
    return await db.insert('vaccinations', asiUygulamasi.toMap());
  }

  Future<AsiUygulamasi?> getVaccinationApplication(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'vaccinations',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AsiUygulamasi.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AsiUygulamasi>> getAllVaccinationApplications() async {
    final db = await instance.database;
    final result = await db.query('vaccinations', orderBy: 'asiTarihi DESC');
    return result.map((json) => AsiUygulamasi.fromMap(json)).toList();
  }

  Future<List<AsiUygulamasi>> getVaccinationApplicationsByAnimal(String kupeNo) async {
    final db = await instance.database;
    final result = await db.query(
      'vaccinations',
      where: 'kupeNo = ?',
      whereArgs: [kupeNo],
      orderBy: 'asiTarihi DESC',
    );
    return result.map((json) => AsiUygulamasi.fromMap(json)).toList();
  }

  Future<int> updateVaccinationApplication(AsiUygulamasi asiUygulamasi) async {
    final db = await instance.database;
    return db.update(
      'vaccinations',
      asiUygulamasi.toMap(),
      where: 'id = ?',
      whereArgs: [asiUygulamasi.id],
    );
  }

  Future<int> deleteVaccinationApplication(int id) async {
    final db = await instance.database;
    return await db.delete(
      'vaccinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Aşı Takvimi metodları
  Future<int> insertVaccineSchedule(DateTime date, String time, String notes, String vaccine) async {
    final db = await instance.database;
    try {
      return await db.insert(
        'vaccineScheduleTable',
        {
          'date': '${DateFormat('yyyy-MM-dd').format(date)}T00:00:00.000Z',
          'time': time,
          'notes': notes,
          'vaccine': vaccine
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting event: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getVaccineSchedules() async {
    final db = await instance.database;
    return await db.query('vaccineScheduleTable');
  }

  Future<void> deleteVaccineSchedule(int id) async {
    final db = await instance.database;
    try {
      await db.delete(
        'vaccineScheduleTable',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting event: $e");
    }
  }
  
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
