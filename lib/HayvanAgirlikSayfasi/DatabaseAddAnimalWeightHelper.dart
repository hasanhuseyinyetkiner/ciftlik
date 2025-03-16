import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'ExcelHelper.dart';

class DatabaseAddAnimalWeightHelper {
  static final DatabaseAddAnimalWeightHelper instance = DatabaseAddAnimalWeightHelper._instance();
  static Database? _db;

  DatabaseAddAnimalWeightHelper._instance();

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    final merlabDb = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Weight (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weight REAL,
            animalid INTEGER,
            date TEXT,
            FOREIGN KEY (animalid) REFERENCES Animal(id)
          )
        ''');
      },
    );
    return merlabDb;
  }

  Future<int> addWeight(Map<String, dynamic> weightDetails) async {
    Database? db = await this.db;
    return await db!.insert('Weight', weightDetails);
  }

  Future<List<Map<String, dynamic>>> getWeightsByAnimalId(int animalId) async {
    Database? db = await this.db;
    return await db!.query(
      'Weight',
      where: 'animalid = ?',
      whereArgs: [animalId],
    );
  }

  Future<int> deleteWeight(int id) async {
    Database? db = await this.db;
    return await db!.delete(
      'Weight',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Son ağırlık kaydını getiren fonksiyon
  Future<Map<String, dynamic>?> getLastWeightByAnimalId(int animalId) async {
    Database? db = await this.db;
    List<Map<String, dynamic>> result = await db!.query(
      'Weight',
      columns: ['animalid', 'weight'],
      where: 'animalid = ?',
      whereArgs: [animalId],
      orderBy: 'id DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
  Stream<double?> getLastWeightStream(int animalId) async* {
    while (true) {
      Map<String, dynamic>? lastWeightRecord = await DatabaseAddAnimalWeightHelper.instance.getLastWeightByAnimalId(animalId);

      if (lastWeightRecord != null) {
        yield lastWeightRecord['weight']; // Son alınan ağırlık verisini döndürüyoruz
      } else {
        yield 0.0; // Veri yoksa sıfır olarak döndürüyoruz
      }

      await Future.delayed(const Duration(seconds: 2)); // 2 saniyelik gecikme
    }
  }
  Future<Map<String, dynamic>?> getAnimalWeightDetails(int animalId) async {
    print('Alınan animalId: $animalId');
    Database? db = await this.db;

    try {
      // Son ağırlığı çekiyoruz
      List<Map<String, dynamic>> lastWeightResult = await db!.rawQuery('''
    SELECT Weight.weight 
    FROM Weight 
    WHERE Weight.animalid = ? 
    ORDER BY Weight.id DESC 
    LIMIT 1;
    ''', [animalId]);

      if (lastWeightResult.isEmpty) {
        print('Son ağırlık verisi bulunamadı');
        return {
          'tagNo': await _getTagNo(db, animalId),
          'last_weight': null,
          'weight_diff': "Son Ağırlık Değişimi: Son ağırlık değişimi hesaplanabilmesi için en az iki ağırlık gerekli",
          'weight_percentage_change': "Son Ağırlık Değişimi Yüzdesi: Son ağırlık değişimi yüzdesi hesaplanabilmesi için en az iki ağırlık gerekli",
          'date_difference': "Gün Farkı: Gün farkı hesaplanabilmesi için en az iki ağırlık gerekli"
        };
      }

      // Ağırlık farkını hesaplıyoruz
      List<Map<String, dynamic>> weightDiffResult = await db.rawQuery('''
  SELECT 
    ROUND(
      (SELECT Weight.weight 
       FROM Weight 
       WHERE Weight.animalid = ? 
       ORDER BY Weight.id DESC  
       LIMIT 1) - 
      (SELECT Weight.weight 
       FROM Weight 
       WHERE Weight.animalid = ? 
       ORDER BY Weight.id DESC 
       LIMIT 1 OFFSET 1), 2) AS weight_diff
''', [animalId, animalId]);


      // Eğer sadece bir tane ağırlık kaydı varsa
      if (weightDiffResult.isEmpty || weightDiffResult.first['weight_diff'] == null) {
        return {
          'tagNo': await _getTagNo(db, animalId),
          'last_weight': lastWeightResult.first['weight'],
          'weight_diff': "Son Ağırlık Değişimi: Son ağırlık değişimi hesaplanabilmesi için bir ağırlık daha gerekli",
          'weight_percentage_change': "Son Ağırlık Değişimi Yüzdesi: Son ağırlık değişimi yüzdesi hesaplanabilmesi için bir ağırlık daha gerekli",
          'date_difference': "Gün Farkı: Gün farkı hesaplanabilmesi için bir ağırlık daha gerekli"
        };
      }

      // Yüzdelik değişimi hesaplıyoruz
      List<Map<String, dynamic>> weightPercentageChangeResult = await db.rawQuery('''
    SELECT 
      ROUND(
        ((SELECT Weight.weight 
          FROM Weight 
          WHERE Weight.animalid = ? 
          ORDER BY Weight.id DESC 
          LIMIT 1) - 
         (SELECT Weight.weight 
          FROM Weight 
          WHERE Weight.animalid = ? 
          ORDER BY Weight.id DESC 
          LIMIT 1 OFFSET 1)) / 
        (SELECT Weight.weight 
         FROM Weight 
         WHERE Weight.animalid = ? 
         ORDER BY Weight.id DESC 
         LIMIT 1 OFFSET 1) * 100, 2) AS weight_percentage_change
    ''', [animalId, animalId, animalId]);

      // Tarih farkını hesaplıyoruz
      List<Map<String, dynamic>> dateDifferenceResult = await db.rawQuery('''
SELECT 
  CAST(ROUND(julianday(
    (SELECT 
        date(
          substr(Weight.date, -4) || '-' || 
          CASE 
              WHEN instr(Weight.date, 'Ocak') > 0 THEN '01' 
              WHEN instr(Weight.date, 'Şubat') > 0 THEN '02' 
              WHEN instr(Weight.date, 'Mart') > 0 THEN '03'
              WHEN instr(Weight.date, 'Nisan') > 0 THEN '04'
              WHEN instr(Weight.date, 'Mayıs') > 0 THEN '05'
              WHEN instr(Weight.date, 'Haziran') > 0 THEN '06'
              WHEN instr(Weight.date, 'Temmuz') > 0 THEN '07'
              WHEN instr(Weight.date, 'Ağustos') > 0 THEN '08'
              WHEN instr(Weight.date, 'Eylül') > 0 THEN '09'
              WHEN instr(Weight.date, 'Ekim') > 0 THEN '10'
              WHEN instr(Weight.date, 'Kasım') > 0 THEN '11'
              WHEN instr(Weight.date, 'Aralık') > 0 THEN '12'
          END || '-' || 
          CASE 
              WHEN length(trim(substr(Weight.date, 1, instr(Weight.date, ' ') - 1))) = 1 
              THEN '0' || trim(substr(Weight.date, 1, instr(Weight.date, ' ') - 1))
              ELSE trim(substr(Weight.date, 1, instr(Weight.date, ' ') - 1))
          END)
     FROM Weight 
     WHERE Weight.animalid = ? 
     ORDER BY Weight.id DESC 
     LIMIT 1)
  ) - julianday(
    (SELECT 
        date(
          substr(Weight.date, -4) || '-' || 
          CASE 
              WHEN instr(Weight.date, 'Ocak') > 0 THEN '01' 
              WHEN instr(Weight.date, 'Şubat') > 0 THEN '02' 
              WHEN instr(Weight.date, 'Mart') > 0 THEN '03'
              WHEN instr(Weight.date, 'Nisan') > 0 THEN '04'
              WHEN instr(Weight.date, 'Mayıs') > 0 THEN '05'
              WHEN instr(Weight.date, 'Haziran') > 0 THEN '06'
              WHEN instr(Weight.date, 'Temmuz') > 0 THEN '07'
              WHEN instr(Weight.date, 'Ağustos') > 0 THEN '08'
              WHEN instr(Weight.date, 'Eylül') > 0 THEN '09'
              WHEN instr(Weight.date, 'Ekim') > 0 THEN '10'
              WHEN instr(Weight.date, 'Kasım') > 0 THEN '11'
              WHEN instr(Weight.date, 'Aralık') > 0 THEN '12'
          END || '-' || 
          CASE 
              WHEN length(trim(substr(Weight.date, 1, instr(Weight.date, ' ') - 1))) = 1 
              THEN '0' || trim(substr(Weight.date, 1, instr(Weight.date, ' ') - 1))
              ELSE trim(substr(Weight.date, 1, instr(Weight.date, ' ') - 1))
          END)
     FROM Weight 
     WHERE Weight.animalid = ? 
     ORDER BY Weight.id DESC 
     LIMIT 1 OFFSET 1)
  ), 0) AS INTEGER) AS date_difference
''', [animalId, animalId]);


      // Sonuçları birleştiriyoruz
      Map<String, dynamic> result = {
        'tagNo': await _getTagNo(db, animalId),
        'last_weight': lastWeightResult.first['weight'],
        'weight_diff': weightDiffResult.first['weight_diff'] ?? "Son ağırlık değişimi bulunamadı",
        'weight_percentage_change': weightPercentageChangeResult.first['weight_percentage_change'] ?? "Son ağırlık değişimi yüzdesi bulunamadı",
        'date_difference': dateDifferenceResult.first['date_difference'] ?? "Gün farkı bulunamadı"
      };

      print('Tüm Veriler: $result');
      return result;

    } catch (e) {
      print('SQL Hatası: $e');
      return null;
    }
  }

  Future<String?> _getTagNo(Database db, int animalId) async {
    List<Map<String, dynamic>> tagNoResult = await db.rawQuery('''
    SELECT tagNo 
    FROM Animal 
    WHERE id = ?;
  ''', [animalId]);

    if (tagNoResult.isNotEmpty) {
      return tagNoResult.first['tagNo'] as String?;
    } else {
      return "TagNo bulunamadı";
    }
  }
  void exportToExcelWithTagNo(int animalId) async {
    var dbHelper = DatabaseAddAnimalWeightHelper.instance;
    var weightDetails = await dbHelper.getAnimalWeightDetails(animalId);

    if (weightDetails != null) {
      String? tagNo = weightDetails['tagNo'];
      List<dynamic> weights = await dbHelper.getWeightsByAnimalId(animalId);

      if (weights.isNotEmpty && tagNo != null) {
        ExcelHelper.exportToExcel(animalId, weights, tagNo);
      } else {
        Get.snackbar('Uyarı', 'Ağırlık veya tagNo verisi bulunamadı');
      }
    }
  }
}
