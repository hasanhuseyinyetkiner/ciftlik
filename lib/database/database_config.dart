import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static final DatabaseConfig _instance = DatabaseConfig._internal();
  PostgreSQLConnection? _connection;

  factory DatabaseConfig() {
    return _instance;
  }

  DatabaseConfig._internal();

  Future<PostgreSQLConnection> get connection async {
    if (_connection == null || _connection!.isClosed) {
      await _initConnection();
    }
    return _connection!;
  }

  Future<void> _initConnection() async {
    await dotenv.load(fileName: ".env");

    _connection = PostgreSQLConnection(
      dotenv.env['DB_HOST'] ?? 'localhost',
      int.parse(dotenv.env['DB_PORT'] ?? '5432'),
      dotenv.env['DB_NAME'] ?? 'ciftlik_db',
      username: dotenv.env['DB_USER'] ?? 'postgres',
      password: dotenv.env['DB_PASSWORD'] ?? 'postgres',
    );

    try {
      await _connection!.open();
      print('Database connection established successfully');
    } catch (e) {
      print('Error connecting to database: $e');
      rethrow;
    }
  }

  Future<void> closeConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('Database connection closed');
    }
  }
}
