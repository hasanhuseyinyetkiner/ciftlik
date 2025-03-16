import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseFeedStockHelper {
  static final DatabaseFeedStockHelper instance =
      DatabaseFeedStockHelper._instance();
  static Database? _db;

  DatabaseFeedStockHelper._instance();

  String feedStockTable = 'feedStockTable';
  String feedStockDetailTable = 'feedStockDetailTable';
  String colId = 'id';
  String colFeedName = 'feedName';
  String colKuruMadde = 'kuruMadde';
  String colUfl = 'ufl';
  String colMe = 'me';
  String colPdi = 'pdi';
  String colHamProtein = 'hamProtein';
  String colLizin = 'lizin';
  String colMetionin = 'metionin';
  String colKalsiyum = 'kalsiyum';
  String colFosfor = 'fosfor';
  String colAltLimit = 'altLimit';
  String colUstLimit = 'ustLimit';
  String colNotlar = 'notlar';
  String colTur = 'tur';

  String colFeedId = 'feedId'; // Foreign key column
  String colType = 'type';
  String colDate = 'date';
  String colQuantity = 'quantity';
  String colNotes = 'notes';
  String colPrice = 'price';

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
    // feedStockTable oluşturma
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $feedStockTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT, 
        $colFeedName TEXT, 
        $colKuruMadde REAL, 
        $colUfl REAL, 
        $colMe REAL, 
        $colPdi REAL, 
        $colHamProtein REAL, 
        $colLizin REAL, 
        $colMetionin REAL, 
        $colKalsiyum REAL, 
        $colFosfor REAL, 
        $colAltLimit REAL, 
        $colUstLimit REAL, 
        $colNotlar TEXT
        $colTur TEXT

      )
      ''');

    // feedStockDetailTable oluşturma, feedId foreign key olarak tanımlandı
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $feedStockDetailTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT, 
        $colFeedId INTEGER, 
        $colType TEXT, 
        $colDate TEXT, 
        $colQuantity TEXT, 
        $colNotes TEXT, 
        $colPrice TEXT,
        FOREIGN KEY ($colFeedId) REFERENCES $feedStockTable($colId) ON DELETE CASCADE
      )
      ''');
  }

  // Yem ekleme
  Future<int> insertFeedStock(Map<String, dynamic> feedStock) async {
    Database? db = await this.db;
    final int result = await db!.insert(feedStockTable, feedStock);
    return result;
  }

  // İşlem ekleme
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    Database? db = await this.db;
    final int result = await db!.insert(feedStockDetailTable, transaction);
    return result;
  }

  // Yemleri alma
  Future<List<Map<String, dynamic>>> getFeedStocks() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(feedStockTable);
    return result;
  }

  // İlgili yeme ait işlemleri alma
  Future<List<Map<String, dynamic>>> getTransactionsByFeedId(int feedId) async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(
      feedStockDetailTable,
      where: '$colFeedId = ?',
      whereArgs: [feedId],
    );
    return result;
  }

  // Yem silme
  Future<int> deleteFeedStock(int id) async {
    Database? db = await this.db;
    final int result =
        await db!.delete(feedStockTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  // İşlem silme
  Future<int> deleteTransaction(int id) async {
    Database? db = await this.db;
    final int result = await db!
        .delete(feedStockDetailTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  //Tüm işlemleri silme
  Future<int> deleteAllTransactions(int feedId) async {
    Database? db = await this.db;
    return await db!.delete(feedStockDetailTable,
        where: '$colFeedId = ?', whereArgs: [feedId]);
  }

  Future<Map<String, dynamic>?> getLastTransactionByFeedId(int feedId) async {
    Database? db = await this.db;

    final List<Map<String, dynamic>> result = await db!.query(
      'feedStockDetailTable',
      where: 'feedId = ?',
      whereArgs: [feedId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null; // Sonuç yoksa null döndür
    }
  }

  Future<double?> getNetQuantityByFeedId(int feedId) async {
    Database? db = await this.db;

    final List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT 
          SUM(CASE WHEN type = 'purchase' THEN CAST(quantity AS REAL) ELSE 0 END) -
          SUM(CASE WHEN type = 'consumption' THEN CAST(quantity AS REAL) ELSE 0 END) AS net_quantity
      FROM 
          $feedStockDetailTable
      WHERE 
          $colFeedId = ?
      GROUP BY 
          $colFeedId
    ''', [feedId]);

    if (result.isNotEmpty) {
      return result.first['net_quantity'] as double?;
    } else {
      return null; // Sonuç yoksa null döndür
    }
  }

  Future<Map<String, dynamic>?> getFeedStockById(int id) async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(
      feedStockTable,
      where: '$colId = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<int> updateFeedStock(int id, Map<String, dynamic> feedStock) async {
    Database? db = await this.db;
    return await db!.update(
      feedStockTable,
      feedStock,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }
}
