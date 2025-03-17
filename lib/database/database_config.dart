import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

class DatabaseConfig {
  static final DatabaseConfig _instance = DatabaseConfig._internal();
  PostgreSQLConnection? _connection;
  bool _isOfflineMode = false;

  // Maximum connection attempts
  final int _maxRetries = 3;
  final Duration _retryDelay = Duration(seconds: 2);

  factory DatabaseConfig() {
    return _instance;
  }

  DatabaseConfig._internal();

  bool get isOfflineMode => _isOfflineMode;

  Future<PostgreSQLConnection?> get connection async {
    if (_isOfflineMode) {
      return null;
    }

    if (_connection == null || _connection!.isClosed) {
      await _initConnection();
    }
    return _connection;
  }

  Future<bool> checkConnection() async {
    try {
      if (_connection != null && !_connection!.isClosed) {
        // Simple query to check connection
        await _connection!.query('SELECT 1');
        return true;
      }

      // Try to init connection if not exists
      await _initConnection();
      return _connection != null && !_connection!.isClosed;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }

  Future<void> _initConnection() async {
    int retryCount = 0;

    while (retryCount < _maxRetries && !_isOfflineMode) {
      try {
        await dotenv.load(fileName: ".env");

        _connection = PostgreSQLConnection(
          dotenv.env['DB_HOST'] ?? 'localhost',
          int.parse(dotenv.env['DB_PORT'] ?? '5432'),
          dotenv.env['DB_NAME'] ?? 'ciftlik_db',
          username: dotenv.env['DB_USER'] ?? 'postgres',
          password: dotenv.env['DB_PASSWORD'] ?? 'postgres',
          timeoutInSeconds: 10,
        );

        await _connection!.open();
        print('Database connection established successfully');
        _isOfflineMode = false;
        return;
      } catch (e) {
        retryCount++;
        print(
            'Error connecting to database (attempt $retryCount/$_maxRetries): $e');

        if (retryCount < _maxRetries) {
          print('Retrying in ${_retryDelay.inSeconds} seconds...');
          await Future.delayed(_retryDelay);
        } else {
          print('Switching to offline mode after $_maxRetries failed attempts');
          _isOfflineMode = true;
        }
      }
    }
  }

  void setOfflineMode(bool value) {
    _isOfflineMode = value;
  }

  Future<void> closeConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('Database connection closed');
    }
  }
}
