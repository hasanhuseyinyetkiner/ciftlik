import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:collection';

class DatabaseConfig {
  static final DatabaseConfig _instance = DatabaseConfig._internal();

  // Connection pool
  final int _maxPoolSize = 5;
  final Queue<PostgreSQLConnection> _connectionPool =
      Queue<PostgreSQLConnection>();
  final List<PostgreSQLConnection> _inUseConnections = [];

  bool _isOfflineMode = false;
  bool _isInitialized = false;

  // Connection Settings
  final int _maxRetries = 3;
  final Duration _retryDelay = Duration(seconds: 1); // Reduced from 2 seconds
  final Duration _connectionTimeout = Duration(seconds: 5); // Reduced timeout
  final int _queryTimeoutInSeconds = 8; // Set query timeout

  // Cache Connection Settings
  late String _host;
  late int _port;
  late String _databaseName;
  late String _username;
  late String _password;

  factory DatabaseConfig() {
    return _instance;
  }

  DatabaseConfig._internal();

  bool get isOfflineMode => _isOfflineMode;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: ".env");

      // Cache connection parameters to avoid re-parsing
      _host = dotenv.env['DB_HOST'] ?? 'localhost';
      _port = int.parse(dotenv.env['DB_PORT'] ?? '5432');
      _databaseName = dotenv.env['DB_NAME'] ?? 'ciftlik_db';
      _username = dotenv.env['DB_USER'] ?? 'postgres';
      _password = dotenv.env['DB_PASSWORD'] ?? 'postgres';

      _isInitialized = true;

      // Pre-initialize some connections for the pool
      await _initializeConnectionPool(2); // Start with 2 connections
    } catch (e) {
      print('Error initializing database config: $e');
      _isOfflineMode = true;
    }
  }

  Future<void> _initializeConnectionPool(int initialSize) async {
    if (_isOfflineMode) return;

    int successfulConnections = 0;

    for (int i = 0; i < initialSize; i++) {
      try {
        final connection = await _createNewConnection();
        if (connection != null) {
          _connectionPool.add(connection);
          successfulConnections++;
        }
      } catch (e) {
        print('Failed to create connection for pool: $e');
      }
    }

    print(
        'Connection pool initialized with $successfulConnections connections');
  }

  Future<PostgreSQLConnection?> _createNewConnection() async {
    final connection = PostgreSQLConnection(
      _host,
      _port,
      _databaseName,
      username: _username,
      password: _password,
      timeoutInSeconds: _queryTimeoutInSeconds,
      useSSL: true, // Enable SSL for security
    );

    try {
      await connection.open().timeout(_connectionTimeout);
      return connection;
    } catch (e) {
      print('Error creating new connection: $e');
      return null;
    }
  }

  Future<PostgreSQLConnection?> get connection async {
    if (_isOfflineMode) {
      return null;
    }

    if (!_isInitialized) {
      await initialize();
    }

    PostgreSQLConnection? conn = await _getConnectionFromPool();
    if (conn != null) return conn;

    // If we couldn't get a connection from the pool, try to reconnect
    await _initConnection();
    return await _getConnectionFromPool();
  }

  Future<PostgreSQLConnection?> _getConnectionFromPool() async {
    // First, try to get an existing connection from the pool
    if (_connectionPool.isNotEmpty) {
      final conn = _connectionPool.removeFirst();

      // Verify the connection is still valid
      try {
        if (conn.isClosed) {
          // Connection closed, create a new one
          return await _createAndTrackConnection();
        }

        // Test the connection with a simple query
        await conn.query('SELECT 1').timeout(Duration(seconds: 2));

        // Connection is good, track it and return
        _inUseConnections.add(conn);
        return conn;
      } catch (e) {
        print('Pool connection validation failed: $e');
        // Try to close the bad connection
        try {
          await conn.close();
        } catch (_) {}

        // Create a new connection instead
        return await _createAndTrackConnection();
      }
    } else if (_inUseConnections.length < _maxPoolSize) {
      // Pool is empty but we can create a new connection
      return await _createAndTrackConnection();
    } else {
      // Pool is empty and we're at max connections
      print('Connection pool exhausted, waiting for an available connection');
      return null;
    }
  }

  Future<PostgreSQLConnection?> _createAndTrackConnection() async {
    final conn = await _createNewConnection();
    if (conn != null) {
      _inUseConnections.add(conn);
    }
    return conn;
  }

  void releaseConnection(PostgreSQLConnection connection) {
    _inUseConnections.remove(connection);

    // Only return to pool if the connection is still valid
    if (!connection.isClosed) {
      _connectionPool.add(connection);
    }
  }

  Future<bool> checkConnection() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final conn = await _getConnectionFromPool();
      if (conn == null) {
        return false;
      }

      // Test with simple query
      await conn.query('SELECT 1');

      // Return connection to pool
      releaseConnection(conn);
      return true;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }

  Future<void> _initConnection() async {
    int retryCount = 0;

    while (retryCount < _maxRetries && !_isOfflineMode) {
      try {
        if (!_isInitialized) {
          await initialize();
        }

        // Try to create at least one connection for the pool
        final connection = await _createNewConnection();
        if (connection != null) {
          _connectionPool.add(connection);
          _isOfflineMode = false;
          print('Database connection established successfully');
          return;
        }
        throw Exception('Failed to create connection');
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

  Future<void> closeAllConnections() async {
    // Close all connections in the pool
    while (_connectionPool.isNotEmpty) {
      final conn = _connectionPool.removeFirst();
      try {
        await conn.close();
      } catch (e) {
        print('Error closing pooled connection: $e');
      }
    }

    // Close all in-use connections
    for (final conn in _inUseConnections) {
      try {
        await conn.close();
      } catch (e) {
        print('Error closing in-use connection: $e');
      }
    }
    _inUseConnections.clear();

    print('All database connections closed');
  }
}
