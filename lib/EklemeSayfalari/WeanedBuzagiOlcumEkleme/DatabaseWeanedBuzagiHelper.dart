import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';  // Gecikme için gerekli

class DatabaseWeanedBuzagiHelper {
  static final DatabaseWeanedBuzagiHelper instance = DatabaseWeanedBuzagiHelper._instance();
  static Database? _db;

  DatabaseWeanedBuzagiHelper._instance();

  String weanedAnimal = 'WeanedAnimal';
  String colId = 'id';
  String colWeight = 'weight';
  String colTagNo = 'tagNo';
  String colDate = 'weaneddate';  // Tarih
  String colTime = 'weanedtime';  // Saat

  String animalTable = 'Animal';
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
      'CREATE TABLE IF NOT EXISTS $weanedAnimal($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colWeight REAL, $colTagNo TEXT, $colDate TEXT, $colTime TEXT)',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS $animalTable($colTagNo TEXT PRIMARY KEY, $colWeaned INTEGER)',
    );
  }

  // Buzagi kaydını ekler veya günceller
  Future<void> insertOrUpdateWeanedBuzagi(String? tagNo, String date, String time) async {
    Database? db = await this.db;

    // Küçük bir gecikme (örneğin 100ms) ekliyoruz
    await Future.delayed(const Duration(milliseconds: 100));

    // Hayvanın zaten kayıtlı olup olmadığını kontrol et
    final List<Map<String, dynamic>> records = await db!.query(
      weanedAnimal,
      where: '$colTagNo = ?',
      whereArgs: [tagNo],
    );

    if (records.isNotEmpty) {
      // Eğer hayvan zaten kayıtlıysa, mevcut kaydı güncelle
      await db.update(
        weanedAnimal,
        {'weaneddate': date, 'weanedtime': time},
        where: '$colTagNo = ?',
        whereArgs: [tagNo],
      );
    } else {
      // Eğer hayvan kayıtlı değilse, yeni bir kayıt oluştur
      await db.insert(
        weanedAnimal,
        {
          'tagNo': tagNo,
          'weaneddate': date,
          'weanedtime': time,
        },
      );
    }
  }

  // Hayvanın 'weaned' statüsünü güncellemek için kullanılan method
  Future<void> updateAnimalWeanedStatus(String? tagNo, int weanedStatus) async {
    Database? db = await this.db;
    await db!.update(
      animalTable,
      {colWeaned: weanedStatus},
      where: '$colTagNo = ?',
      whereArgs: [tagNo],
    );

    // Hayvanın `weaned` statüsünü güncelledikten sonra da gecikme ekleyebiliriz (isteğe bağlı)
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
