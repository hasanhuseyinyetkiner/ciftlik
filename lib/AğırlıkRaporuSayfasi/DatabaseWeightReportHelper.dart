import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseWeightReportHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'merlab.db'); // Veritabanı yolunu belirle
    return await openDatabase(path);
  }

  // Son ağırlık değişimini hesaplayan fonksiyon(Şimdilik kullanılmamakta,ileride kullanılabilir.)
  Future<List<Map<String, dynamic>>> getLastWeightChange(List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');
      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           AT.animaltype, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id DESC 
                 LIMIT 1 OFFSET 1)
            ), 2) AS weight_diff,
           ROUND((
                (((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) * 100), 2) AS weight_diff_percentage,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id DESC 
             LIMIT 1 OFFSET 1)
          ), 0) AS INTEGER) AS date_difference
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid, AT.animaltype
    HAVING weight_diff IS NOT NULL;
    ''');

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Son ağırlık değişimini büyükten küçüğe sıralı olarak hesaplayan fonksiyon(Şimdilik kullanılmamakta,ileride kullanılabilir.)
  Future<List<Map<String, dynamic>>> getLastWeightChangeDesc(List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');
      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           AT.animaltype, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id DESC 
                 LIMIT 1 OFFSET 1)
            ), 2) AS weight_diff,
           ROUND((
                (((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) * 100), 2) AS weight_diff_percentage,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id DESC 
             LIMIT 1 OFFSET 1)
          ), 0) AS INTEGER) AS date_difference
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid, AT.animaltype
    HAVING weight_diff IS NOT NULL
    ORDER BY weight_diff DESC;
    ''');

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Son ağırlık değişimini küçükten büyüğe sıralı olarak hesaplayan fonksiyon(Şimdilik kullanılmamakta,ileride kullanılabilir.)
  Future<List<Map<String, dynamic>>> getLastWeightChangeAsc(List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekleyin
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           AT.animaltype, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id DESC 
                 LIMIT 1 OFFSET 1)
            ), 2) AS weight_diff,
           ROUND((
                (((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) * 100), 2) AS weight_diff_percentage,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id DESC 
             LIMIT 1 OFFSET 1)
          ), 0) AS INTEGER) AS date_difference
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid, AT.animaltype
    HAVING weight_diff IS NOT NULL
    ORDER BY weight_diff ASC;
    ''');

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Genel ağırlık değişimini hesaplayan fonksiyon(Şimdilik kullanılmamakta,ileride kullanılabilir.)
  Future<List<Map<String, dynamic>>> getGeneralWeightChange(List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekleyin
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           AT.animaltype, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id ASC 
                 LIMIT 1)
            ), 2) AS weight_diff,
           ROUND((
                (((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) * 100), 2) AS weight_diff_percentage,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id ASC 
             LIMIT 1)
          ), 0) AS INTEGER) AS date_difference
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid, AT.animaltype
    HAVING weight_diff IS NOT NULL;
    ''');

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Genel ağırlık değişimini hesaplayan fonksiyon (Büyükten küçüğe sıralama)(Şimdilik kullanılmamakta,ileride kullanılabilir.)
  Future<List<Map<String, dynamic>>> getGeneralWeightChangeDesc(List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           AT.animaltype, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id ASC 
                 LIMIT 1)
            ), 2) AS weight_diff,
           ROUND((
                (((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) * 100), 2) AS weight_diff_percentage,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id ASC 
             LIMIT 1)
          ), 0) AS INTEGER) AS date_difference
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid, AT.animaltype
    HAVING weight_diff IS NOT NULL
    ORDER BY weight_diff DESC;
    ''');

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Genel ağırlık değişimini hesaplayan fonksiyon (Küçükten büyüğe sıralama)(Şimdilik kullanılmamakta,ileride kullanılabilir.)
  Future<List<Map<String, dynamic>>> getGeneralWeightChangeAsc(List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           AT.animaltype, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id ASC 
                 LIMIT 1)
            ), 2) AS weight_diff,
           ROUND((
                (((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) * 100), 2) AS weight_diff_percentage,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id ASC 
             LIMIT 1)
          ), 0) AS INTEGER) AS date_difference
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid, AT.animaltype
    HAVING weight_diff IS NOT NULL
    ORDER BY weight_diff ASC;
    ''');

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Son ağırlık değişimi belirli aralıkta olan hayvanları getiren fonksiyon
  Future<List<Map<String, dynamic>>> getLastWeightChangeBetween(
      double minWeight, double maxWeight, List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid,
           A.tagNo, 
           AT.animaltype,
           A.weaned, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id DESC 
                 LIMIT 1 OFFSET 1)
            ), 2) AS weight_diff_last,
           ROUND((
                ((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) * 100), 2) AS weight_diff_percentage_last,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id DESC 
             LIMIT 1 OFFSET 1)
          ), 0) AS INTEGER) AS date_difference_last
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid,A.tagNo, AT.animaltype,A.weaned
    HAVING COUNT(W.id) > 1
       AND weight_diff_last BETWEEN ? AND ?;
    ''', [minWeight, maxWeight]);

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }


  // Son ağırlık değişimi belirli aralıkta olan hayvanları azalan sırayla getiren fonksiyon
  Future<List<Map<String, dynamic>>> getLastWeightChangeBetweenDesc(
      double minWeight, double maxWeight, List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid,
           A.tagNo, 
           AT.animaltype,
           A.weaned, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id DESC 
                 LIMIT 1 OFFSET 1)
            ), 2) AS weight_diff_last,
           ROUND((
                ((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) * 100), 2) AS weight_diff_percentage_last,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id DESC 
             LIMIT 1 OFFSET 1)
          ), 0) AS INTEGER) AS date_difference_last
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid,A.tagNo, AT.animaltype,A.weaned
    HAVING COUNT(W.id) > 1
       AND weight_diff_last BETWEEN ? AND ?
    ORDER BY weight_diff_last DESC;
    ''', [minWeight, maxWeight]);

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Son ağırlık değişimi belirli aralıkta olan hayvanları artan sırayla getiren fonksiyon
  Future<List<Map<String, dynamic>>> getLastWeightChangeBetweenAsc(
      double minWeight, double maxWeight, List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid, 
           A.tagNo,
           AT.animaltype,
           A.weaned, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id DESC 
                 LIMIT 1 OFFSET 1)
            ), 2) AS weight_diff_last,
           ROUND((
                ((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id DESC 
                     LIMIT 1 OFFSET 1)
                ) * 100), 2) AS weight_diff_percentage_last,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id DESC 
             LIMIT 1 OFFSET 1)
          ), 0) AS INTEGER) AS date_difference_last
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid,A.tagNo, AT.animaltype,A.weaned
    HAVING COUNT(W.id) > 1
       AND weight_diff_last BETWEEN ? AND ?
    ORDER BY weight_diff_last ASC;
    ''', [minWeight, maxWeight]);

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Genel ağırlık değişimi belirli aralıkta olan hayvanları getiren fonksiyon
  Future<List<Map<String, dynamic>>> getGeneralWeightChangeBetween(
      double minWeight, double maxWeight, List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid,
           A.tagNo, 
           AT.animaltype,
           A.weaned, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id ASC 
                 LIMIT 1)
            ), 2) AS weight_diff_general,
           ROUND((
                ((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) * 100), 2) AS weight_diff_percentage_general,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id ASC 
             LIMIT 1)
          ), 0) AS INTEGER) AS date_difference_general
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid,A.tagNo, AT.animaltype,A.weaned
    HAVING COUNT(W.id) > 1
       AND weight_diff_general BETWEEN ? AND ?;
    ''', [minWeight, maxWeight]);

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }


  // Genel ağırlık değişimi belirli aralıkta olan hayvanları azalan sırayla getiren fonksiyon
  Future<List<Map<String, dynamic>>> getGeneralWeightChangeBetweenDesc(
      double minWeight, double maxWeight, List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid,
           A.tagNo, 
           AT.animaltype,
           A.weaned, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id ASC 
                 LIMIT 1)
            ), 2) AS weight_diff_general,
           ROUND((
                ((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) * 100), 2) AS weight_diff_percentage_general,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id ASC 
             LIMIT 1)
          ), 0) AS INTEGER) AS date_difference_general
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid,A.tagNo, AT.animaltype,A.weaned
    HAVING COUNT(W.id) > 1
       AND weight_diff_general BETWEEN ? AND ?
    ORDER BY weight_diff_general DESC;
    ''', [minWeight, maxWeight]);

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }


  // Genel ağırlık değişimi belirli aralıkta olan hayvanları artan sırayla getiren fonksiyon
  Future<List<Map<String, dynamic>>> getGeneralWeightChangeBetweenAsc(
      double minWeight, double maxWeight, List<String> selectedAnimals) async {
    Database? db = await database;

    try {
      // selectedAnimals listesini dinamik olarak SQL sorgusuna ekliyoruz
      String animalTypes = selectedAnimals.map((animal) => "'$animal'").join(',');

      List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT W.animalid,
           A.tagNo, 
           AT.animaltype,
           A.weaned, 
           ROUND((
                (SELECT w1.weight 
                 FROM Weight w1 
                 WHERE w1.animalid = W.animalid 
                 ORDER BY w1.id DESC  
                 LIMIT 1) - 
                (SELECT w2.weight 
                 FROM Weight w2 
                 WHERE w2.animalid = W.animalid
                 ORDER BY w2.id ASC 
                 LIMIT 1)
            ), 2) AS weight_diff_general,
           ROUND((
                ((
                    (SELECT w1.weight 
                     FROM Weight w1 
                     WHERE w1.animalid = W.animalid 
                     ORDER BY w1.id DESC  
                     LIMIT 1) - 
                    (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) / (SELECT w2.weight 
                     FROM Weight w2 
                     WHERE w2.animalid = W.animalid
                     ORDER BY w2.id ASC 
                     LIMIT 1)
                ) * 100), 2) AS weight_diff_percentage_general,
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
             WHERE Weight.animalid = W.animalid 
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
             WHERE Weight.animalid = W.animalid 
             ORDER BY Weight.id ASC 
             LIMIT 1)
          ), 0) AS INTEGER) AS date_difference_general
    FROM Weight W
    JOIN Animal A ON W.animalid = A.id
    JOIN AnimalSubType AST ON A.animalsubtypeid = AST.id
    JOIN AnimalType AT ON AST.animaltypeid = AT.id
    WHERE AT.animaltype IN ($animalTypes)
    GROUP BY W.animalid,A.tagNo, AT.animaltype,A.weaned
    HAVING COUNT(W.id) > 1
       AND weight_diff_general BETWEEN ? AND ?
    ORDER BY weight_diff_general ASC;
    ''', [minWeight, maxWeight]);

      return result;
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }
}
