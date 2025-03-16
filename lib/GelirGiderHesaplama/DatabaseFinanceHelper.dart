import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseFinanceHelper {
  static final DatabaseFinanceHelper instance = DatabaseFinanceHelper._instance();
  static Database? _db;

  DatabaseFinanceHelper._instance();

  String financeTable = 'FinanceTable';
  String colId = 'id';
  String colDate = 'date';
  String colName = 'name';
  String colNote = 'note';
  String colAmount = 'amount';
  String colType = 'type';

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
      'CREATE TABLE IF NOT EXISTS $financeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDate TEXT, $colName TEXT, $colNote TEXT, $colAmount REAL, $colType TEXT)',
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    Database? db = await this.db;
    final int result = await db!.insert(financeTable, transaction);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(financeTable);
    return result;
  }

  Future<int> deleteTransaction(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(financeTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }
}
