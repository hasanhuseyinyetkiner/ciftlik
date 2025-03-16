import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../database/database_config.dart';

class DatabaseService {
  PostgreSQLConnection? _connection;
  final DatabaseConfig _dbConfig = DatabaseConfig();
  bool _isConnected = false;
  int _maxRetries = 3;
  int _retryDelaySeconds = 2;

  bool get isConnected => _isConnected;

  Future<void> init() async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        _connection = await _dbConfig.connection;
        _isConnected = true;
        print('Database connection established successfully');
        return;
      } catch (e) {
        retryCount++;
        print('Database connection attempt $retryCount failed: $e');
        if (retryCount < _maxRetries) {
          print('Retrying in $_retryDelaySeconds seconds...');
          await Future.delayed(Duration(seconds: _retryDelaySeconds));
        }
      }
    }
    _isConnected = false;
    print(
        'Database connection failed after $_maxRetries attempts. Running in offline mode.');
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    if (!_isConnected || _connection == null) {
      print('Warning: Database is offline, returning empty result for query');
      return [];
    }

    try {
      final results = await _connection!.mappedResultsQuery(
        sql,
        substitutionValues: substitutionValues,
      );
      return results.map((r) => r.values.first).toList();
    } catch (e) {
      print('Error executing query: $e');
      if (e is PostgreSQLException) {
        print('PostgreSQL error code: ${e.code}');
      }
      return [];
    }
  }

  Future<bool> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    if (!_isConnected || _connection == null) {
      print('Warning: Database is offline, skipping execute operation');
      return false;
    }

    try {
      await _connection!.execute(sql, substitutionValues: substitutionValues);
      return true;
    } catch (e) {
      print('Error executing command: $e');
      if (e is PostgreSQLException) {
        print('PostgreSQL error code: ${e.code}');
      }
      return false;
    }
  }

  Future<T?> transaction<T>(
    Future<T> Function(PostgreSQLConnection) operation,
  ) async {
    if (!_isConnected || _connection == null) {
      print('Warning: Database is offline, skipping transaction');
      return null;
    }

    try {
      return await _connection!.transaction((ctx) async {
        return await operation(_connection!);
      });
    } catch (e) {
      print('Error in transaction: $e');
      if (e is PostgreSQLException) {
        print('PostgreSQL error code: ${e.code}');
      }
      return null;
    }
  }

  Future<void> close() async {
    if (_connection != null && _isConnected) {
      try {
        await _connection!.close();
        _isConnected = false;
        print('Database connection closed successfully');
      } catch (e) {
        print('Error closing database connection: $e');
      }
    }
  }

  Future<bool> reconnect() async {
    print('Attempting to reconnect to database...');
    try {
      await close();
      await init();
      return _isConnected;
    } catch (e) {
      print('Error reconnecting to database: $e');
      return false;
    }
  }

  // Weight Analysis Module Database Methods
  Future<List<Map<String, dynamic>>> getWeightAnalysisData(
    int period,
    String group,
    double minWeight,
    double maxWeight,
  ) async {
    try {
      if (!_isConnected || _connection == null) {
        return [];
      }

      String sql = '''
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
            AND date >= NOW() - INTERVAL '$period days'
          ) as totalGain
        FROM weight_reports w
        JOIN animals a ON w.animal_id = a.id
        WHERE w.date >= NOW() - INTERVAL '$period days'
      ''';

      Map<String, dynamic> params = {};
      List<String> conditions = [];

      if (group.isNotEmpty && group != 'Tüm Gruplar') {
        conditions.add("a.group_name = @group");
        params['group'] = group;
      }

      if (minWeight > 0) {
        conditions.add("w.weight >= @minWeight");
        params['minWeight'] = minWeight;
      }

      if (maxWeight > 0) {
        conditions.add("w.weight <= @maxWeight");
        params['maxWeight'] = maxWeight;
      }

      if (conditions.isNotEmpty) {
        sql += ' AND ${conditions.join(' AND ')}';
      }

      sql += ' ORDER BY w.date DESC';

      final results = await _connection!
          .mappedResultsQuery(sql, substitutionValues: params);
      return results.map((r) => r.values.first).toList();
    } catch (e) {
      print('Error in getWeightAnalysisData: $e');
      // Return sample data in case of error
      return _getSampleWeightData(period);
    }
  }

  List<Map<String, dynamic>> _getSampleWeightData(int period) {
    // Generate sample weight data for demonstration
    final today = DateTime.now();
    List<Map<String, dynamic>> mockData = [];

    for (int i = 0; i < 10; i++) {
      final date = today.subtract(Duration(days: i * 3));
      final baseWeight = 350.0 + (10 - i) * 2.5; // Weight increases over time
      final randomVariation = (DateTime.now().millisecondsSinceEpoch % 10) / 10;

      mockData.add({
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'weight': baseWeight + randomVariation,
        'animal_id': 1001,
        'name': 'Demo Hayvan',
        'group_name': 'Demo Grup',
        'gain': i > 0 ? 2.5 + randomVariation : 0.0,
        'totalGain': (10 - i) * 2.5,
      });
    }

    return mockData;
  }

  // Auto Weight Module Database Methods
  Future<String?> getLastConnectedDeviceId() async {
    try {
      if (!_isConnected || _connection == null) {
        return null;
      }

      final sql = "SELECT value FROM settings WHERE key = @key";
      final results = await _connection!.mappedResultsQuery(
        sql,
        substitutionValues: {'key': 'last_connected_device'},
      );

      if (results.isEmpty || results.first.values.isEmpty) {
        return null;
      }

      return results.first.values.first['value'] as String?;
    } catch (e) {
      print('Error in getLastConnectedDeviceId: $e');
      return null;
    }
  }

  Future<void> saveLastConnectedDeviceId(String deviceId) async {
    try {
      if (!_isConnected || _connection == null) {
        return;
      }

      // First try to update if the record exists
      final updateSql = '''
        UPDATE settings 
        SET value = @value 
        WHERE key = @key
      ''';

      final updateResult = await _connection!.execute(updateSql,
          substitutionValues: {
            'key': 'last_connected_device',
            'value': deviceId
          });

      // If no rows were affected, insert a new record
      if (updateResult == 0) {
        final insertSql = '''
          INSERT INTO settings (key, value)
          VALUES (@key, @value)
        ''';

        await _connection!.execute(insertSql, substitutionValues: {
          'key': 'last_connected_device',
          'value': deviceId
        });
      }
    } catch (e) {
      print('Error in saveLastConnectedDeviceId: $e');
    }
  }

  Future<void> saveWeightRecord(Map<String, dynamic> record) async {
    try {
      if (!_isConnected || _connection == null) {
        return;
      }

      final sql = '''
        INSERT INTO auto_weight_records 
        (weight, timestamp, deviceId, ruleApplied, category)
        VALUES 
        (@weight, @timestamp, @deviceId, @ruleApplied, @category)
      ''';

      await _connection!.execute(sql, substitutionValues: {
        'weight': record['weight'],
        'timestamp': record['timestamp'],
        'deviceId': record['deviceId'],
        'ruleApplied': record['ruleApplied'],
        'category': record['category'],
      });
    } catch (e) {
      print('Error in saveWeightRecord: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSeparationRules() async {
    try {
      if (!_isConnected || _connection == null) {
        return _getDefaultSeparationRules();
      }

      final sql = "SELECT * FROM separation_rules ORDER BY minWeight";
      final results = await _connection!.mappedResultsQuery(sql);

      if (results.isEmpty) {
        return _getDefaultSeparationRules();
      }

      return results.map((r) => r.values.first).toList();
    } catch (e) {
      print('Error in getSeparationRules: $e');
      return _getDefaultSeparationRules();
    }
  }

  List<Map<String, dynamic>> _getDefaultSeparationRules() {
    return [
      {
        'id': 1,
        'name': 'Küçük Hayvanlar',
        'minWeight': 0.0,
        'maxWeight': 300.0,
        'category': 'A',
      },
      {
        'id': 2,
        'name': 'Orta Boyutlu Hayvanlar',
        'minWeight': 300.1,
        'maxWeight': 600.0,
        'category': 'B',
      },
      {
        'id': 3,
        'name': 'Büyük Hayvanlar',
        'minWeight': 600.1,
        'maxWeight': 1000.0,
        'category': 'C',
      },
    ];
  }

  Future<Map<String, dynamic>> getWeightingStats() async {
    try {
      if (!_isConnected || _connection == null) {
        return _getDefaultWeightingStats();
      }

      final sql = "SELECT * FROM auto_weight_stats ORDER BY id DESC LIMIT 1";
      final results = await _connection!.mappedResultsQuery(sql);

      if (results.isEmpty || results.first.values.isEmpty) {
        return _getDefaultWeightingStats();
      }

      // Convert PostgreSQL result to Map<String, dynamic>
      return results.first.values.first;
    } catch (e) {
      print('Error in getWeightingStats: $e');
      return _getDefaultWeightingStats();
    }
  }

  Map<String, dynamic> _getDefaultWeightingStats() {
    return {
      'totalWeighings': 0,
      'errorRate': 0.0,
      'lastSync': DateTime.now().toIso8601String(),
    };
  }

  Future<void> saveWeightingStats(Map<String, Object> stats) async {
    try {
      if (!_isConnected || _connection == null) {
        return;
      }

      final data = {
        'totalWeighings': stats['totalWeighings'],
        'errorRate': stats['errorRate'],
        'lastSync': (stats['lastSync'] as DateTime).toIso8601String(),
      };

      // First try to update if records exist
      final updateSql = '''
        UPDATE auto_weight_stats 
        SET totalWeighings = @totalWeighings, 
            errorRate = @errorRate, 
            lastSync = @lastSync
        WHERE id = (SELECT id FROM auto_weight_stats ORDER BY id DESC LIMIT 1)
      ''';

      final updateResult =
          await _connection!.execute(updateSql, substitutionValues: data);

      // If no rows were affected, insert a new record
      if (updateResult == 0) {
        final insertSql = '''
          INSERT INTO auto_weight_stats 
          (totalWeighings, errorRate, lastSync)
          VALUES 
          (@totalWeighings, @errorRate, @lastSync)
        ''';

        await _connection!.execute(insertSql, substitutionValues: data);
      }
    } catch (e) {
      print('Error in saveWeightingStats: $e');
    }
  }

  // Ensure weight module tables are created
  Future<void> createWeightModuleTables() async {
    try {
      if (!_isConnected || _connection == null) {
        return;
      }

      // Weight Reports table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS weight_reports (
          id SERIAL PRIMARY KEY,
          animal_id INTEGER NOT NULL,
          date TIMESTAMP NOT NULL,
          weight REAL NOT NULL,
          notes TEXT
        )
      ''');

      // Auto Weight Records table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS auto_weight_records (
          id SERIAL PRIMARY KEY,
          weight REAL NOT NULL,
          timestamp TIMESTAMP NOT NULL,
          deviceId TEXT,
          ruleApplied TEXT,
          category TEXT,
          error BOOLEAN DEFAULT FALSE
        )
      ''');

      // Settings table for device information
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');

      // Separation rules table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS separation_rules (
          id SERIAL PRIMARY KEY,
          name TEXT NOT NULL,
          minWeight REAL NOT NULL,
          maxWeight REAL NOT NULL,
          category TEXT NOT NULL
        )
      ''');

      // Stats table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS auto_weight_stats (
          id SERIAL PRIMARY KEY,
          totalWeighings INTEGER NOT NULL,
          errorRate REAL NOT NULL,
          lastSync TIMESTAMP NOT NULL
        )
      ''');
    } catch (e) {
      print('Error creating weight module tables: $e');
    }
  }
}
