import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../database/database_config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  final DatabaseConfig _dbConfig = DatabaseConfig();
  bool _isConnected = false;
  int _maxRetries = 3;
  int _retryDelaySeconds = 1; // Reduced from 2 seconds
  static Database? _database;
  bool _isOfflineMode = false;

  // Simple cache implementation
  final Map<String, _CacheEntry> _queryCache = {};
  final Duration _cacheDuration = Duration(minutes: 5);

  bool get isConnected => _isConnected;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ciftlik_yonetim.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  // Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hayvanlar (
        id TEXT PRIMARY KEY,
        kupe_no TEXT,
        tur TEXT,
        irk TEXT,
        cinsiyet TEXT,
        dogum_tarihi TEXT,
        anne_kupe_no TEXT,
        baba_kupe_no TEXT,
        chip_no TEXT,
        rfid TEXT,
        ciftlik_kupe TEXT,
        ciftlik_kupe_rengi TEXT,
        ulusal_kupe TEXT,
        ulusal_kupe_rengi TEXT,
        agirlik REAL,
        durum TEXT,
        gebelik_durumu INTEGER,
        damizlik_durumu INTEGER,
        damizlik_puan INTEGER,
        tip_adi TEXT,
        suru_adi TEXT,
        padok_adi TEXT,
        dogum_numarasi TEXT,
        kardes_sayisi INTEGER,
        kuzu_sayisi INTEGER,
        edinme_tarihi TEXT,
        edinme_yontemi TEXT,
        son_tohumlanma_tarihi TEXT,
        tahmini_dogum_tarihi TEXT,
        notlar TEXT,
        ek_bilgi TEXT,
        aktif INTEGER,
        saglik_durumu TEXT,
        gunluk_sut_uretimi REAL,
        canli_agirlik REAL,
        kuruya_ayirma_tarihi TEXT,
        yedi_gunluk_canli_agirlik_ortalamasi REAL,
        onbes_gunluk_canli_agirlik_ortalamasi REAL,
        otuz_gunluk_canli_agirlik_ortalamasi REAL,
        gunluk_canli_agirlik_artisi REAL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE hayvan_tartimlar (
        id TEXT PRIMARY KEY,
        hayvan_id TEXT,
        tarih TEXT,
        agirlik REAL,
        birim TEXT,
        notlar TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (hayvan_id) REFERENCES hayvanlar (id)
      )
    ''');

    // Add other necessary tables...
  }

  // Upgrade database
  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Initialize database service
  Future<void> init() async {
    await database;
    _isConnected = true;
  }

  // Set offline mode
  void setOfflineMode(bool value) {
    _isOfflineMode = value;
    _isConnected = !value;
  }

  // Check database connection
  Future<bool> checkConnection() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      _isConnected = true;
      return true;
    } catch (e) {
      print('Database connection error: $e');
      _isConnected = false;
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
    bool useCache = true,
    Duration? cacheDuration,
  }) async {
    if (!_isConnected) {
      print('Warning: Database is offline, returning empty result for query');
      return [];
    }

    // Create a cache key from the query and parameters
    final cacheKey = _createCacheKey(sql, substitutionValues);

    // Check cache first if enabled
    if (useCache && _queryCache.containsKey(cacheKey)) {
      final cacheEntry = _queryCache[cacheKey]!;
      if (!cacheEntry.isExpired()) {
        print('Returning cached result for query');
        return cacheEntry.data;
      } else {
        // Remove expired entry
        _queryCache.remove(cacheKey);
      }
    }

    PostgreSQLConnection? connection;
    try {
      connection = await _dbConfig.connection;
      if (connection == null) {
        print(
            'Warning: Could not get database connection, returning empty result');
        return [];
      }

      final results = await connection.mappedResultsQuery(
        sql,
        substitutionValues: substitutionValues,
      );

      final mappedResults = results.map((r) => r.values.first).toList();

      // Cache the result if caching is enabled
      if (useCache) {
        _queryCache[cacheKey] = _CacheEntry(
          mappedResults,
          cacheDuration ?? _cacheDuration,
        );
      }

      return mappedResults;
    } catch (e) {
      print('Error executing query: $e');
      if (e is PostgreSQLException) {
        print('PostgreSQL error code: ${e.code}');
      }
      return [];
    } finally {
      // Always release the connection back to the pool
      if (connection != null) {
        _dbConfig.releaseConnection(connection);
      }
    }
  }

  Future<bool> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    if (!_isConnected) {
      print('Warning: Database is offline, skipping execute operation');
      return false;
    }

    PostgreSQLConnection? connection;
    try {
      connection = await _dbConfig.connection;
      if (connection == null) {
        print('Warning: Could not get database connection');
        return false;
      }

      await connection.execute(sql, substitutionValues: substitutionValues);

      // Clear cache after write operations
      _clearRelatedCacheEntries(sql);

      return true;
    } catch (e) {
      print('Error executing command: $e');
      if (e is PostgreSQLException) {
        print('PostgreSQL error code: ${e.code}');
      }
      return false;
    } finally {
      // Always release the connection back to the pool
      if (connection != null) {
        _dbConfig.releaseConnection(connection);
      }
    }
  }

  Future<T?> transaction<T>(
    Future<T> Function(PostgreSQLConnection) operation,
  ) async {
    if (!_isConnected) {
      print('Warning: Database is offline, skipping transaction');
      return null;
    }

    PostgreSQLConnection? connection;
    try {
      connection = await _dbConfig.connection;
      if (connection == null) {
        print('Warning: Could not get database connection');
        return null;
      }

      final result = await connection.transaction((ctx) async {
        return await operation(connection!);
      });

      // Clear all cache after transaction as we don't know what was modified
      _clearAllCache();

      return result;
    } catch (e) {
      print('Error in transaction: $e');
      if (e is PostgreSQLException) {
        print('PostgreSQL error code: ${e.code}');
      }
      return null;
    } finally {
      // Always release the connection back to the pool
      if (connection != null) {
        _dbConfig.releaseConnection(connection);
      }
    }
  }

  Future<void> close() async {
    try {
      await _dbConfig.closeAllConnections();
      _isConnected = false;
      print('Database connections closed successfully');
    } catch (e) {
      print('Error closing database connections: $e');
    }
  }

  Future<bool> reconnect() async {
    print('Attempting to reconnect to database...');
    try {
      _isConnected = false;
      await init();
      return _isConnected;
    } catch (e) {
      print('Error reconnecting to database: $e');
      return false;
    }
  }

  // Cache management methods
  String _createCacheKey(String sql, Map<String, dynamic>? params) {
    return '$sql:${params != null ? jsonEncode(params) : ""}';
  }

  void _clearRelatedCacheEntries(String sql) {
    // Simple table detection - this can be improved
    final tablePattern =
        RegExp(r'(?:FROM|INTO|UPDATE|JOIN)\s+([a-zA-Z_][a-zA-Z0-9_]*)');
    final matches = tablePattern.allMatches(sql);

    if (matches.isEmpty) {
      // If we can't determine tables, clear all cache to be safe
      _clearAllCache();
      return;
    }

    // Get table names
    final tableNames = matches
        .map((m) => m.group(1)?.toLowerCase())
        .where((t) => t != null)
        .toSet();

    // Remove cache entries related to these tables
    _queryCache.removeWhere((key, _) {
      return tableNames.any((table) => key.toLowerCase().contains(table!));
    });
  }

  void _clearAllCache() {
    _queryCache.clear();
    print('All query cache cleared');
  }

  // Persistent cache methods using SharedPreferences for frequently accessed data
  Future<void> saveToPersistentCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(data);
      await prefs.setString('db_cache_$key', jsonData);
    } catch (e) {
      print('Error saving to persistent cache: $e');
    }
  }

  Future<dynamic> getFromPersistentCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('db_cache_$key');
      if (jsonData == null) return null;
      return jsonDecode(jsonData);
    } catch (e) {
      print('Error retrieving from persistent cache: $e');
      return null;
    }
  }

  Future<void> clearPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('db_cache_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing persistent cache: $e');
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
      if (!_isConnected) {
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

      final results = await query(sql, substitutionValues: params);
      return results;
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
      if (!_isConnected) {
        return null;
      }

      final sql = "SELECT value FROM settings WHERE key = @key";
      final results = await query(sql,
          substitutionValues: {'key': 'last_connected_device'});

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
      if (!_isConnected) {
        return;
      }

      // First try to update if the record exists
      final updateSql = '''
        UPDATE settings 
        SET value = @value 
        WHERE key = @key
      ''';

      final updateResult = await execute(updateSql, substitutionValues: {
        'key': 'last_connected_device',
        'value': deviceId
      });

      // If no rows were affected, insert a new record
      if (updateResult == 0) {
        final insertSql = '''
          INSERT INTO settings (key, value)
          VALUES (@key, @value)
        ''';

        await execute(insertSql, substitutionValues: {
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
      if (!_isConnected) {
        return;
      }

      final sql = '''
        INSERT INTO auto_weight_records 
        (weight, timestamp, deviceId, ruleApplied, category)
        VALUES 
        (@weight, @timestamp, @deviceId, @ruleApplied, @category)
      ''';

      await execute(sql, substitutionValues: {
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
      if (!_isConnected) {
        return _getDefaultSeparationRules();
      }

      final sql = "SELECT * FROM separation_rules ORDER BY minWeight";
      final results = await query(sql);

      if (results.isEmpty) {
        return _getDefaultSeparationRules();
      }

      return results;
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
      if (!_isConnected) {
        return _getDefaultWeightingStats();
      }

      final sql = "SELECT * FROM auto_weight_stats ORDER BY id DESC LIMIT 1";
      final results = await query(sql);

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
      if (!_isConnected) {
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

      final updateResult = await execute(updateSql, substitutionValues: data);

      // If no rows were affected, insert a new record
      if (updateResult == 0) {
        final insertSql = '''
          INSERT INTO auto_weight_stats 
          (totalWeighings, errorRate, lastSync)
          VALUES 
          (@totalWeighings, @errorRate, @lastSync)
        ''';

        await execute(insertSql, substitutionValues: data);
      }
    } catch (e) {
      print('Error in saveWeightingStats: $e');
    }
  }

  // Ensure weight module tables are created
  Future<void> createWeightModuleTables() async {
    try {
      if (!_isConnected) {
        return;
      }

      // Weight Reports table
      await execute('''
        CREATE TABLE IF NOT EXISTS weight_reports (
          id SERIAL PRIMARY KEY,
          animal_id INTEGER NOT NULL,
          date TIMESTAMP NOT NULL,
          weight REAL NOT NULL,
          notes TEXT
        )
      ''');

      // Auto Weight Records table
      await execute('''
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
      await execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');

      // Separation rules table
      await execute('''
        CREATE TABLE IF NOT EXISTS separation_rules (
          id SERIAL PRIMARY KEY,
          name TEXT NOT NULL,
          minWeight REAL NOT NULL,
          maxWeight REAL NOT NULL,
          category TEXT NOT NULL
        )
      ''');

      // Stats table
      await execute('''
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

  // HAYVAN NOT İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getHayvanNotlari(int hayvanId) async {
    return await query(
      'SELECT * FROM hayvan_not WHERE hayvan_id = ? ORDER BY created_at DESC',
      substitutionValues: {'hayvan_id': hayvanId},
    );
  }

  Future<bool> addHayvanNot(Map<String, dynamic> data) async {
    try {
      await execute(
        'INSERT INTO hayvan_not (hayvan_id, not_metni, kullanici_id, onemli_mi) VALUES (?, ?, ?, ?)',
        substitutionValues: {
          'hayvan_id': data['hayvan_id'],
          'not_metni': data['not_metni'],
          'kullanici_id': data['kullanici_id'],
          'onemli_mi': data['onemli_mi'] ?? false,
        },
      );
      return true;
    } catch (e) {
      print('Error adding hayvan not: $e');
      return false;
    }
  }

  Future<bool> updateHayvanNot(int notId, Map<String, dynamic> data) async {
    try {
      await execute(
        'UPDATE hayvan_not SET not_metni = ?, onemli_mi = ? WHERE not_id = ?',
        substitutionValues: {
          'not_metni': data['not_metni'],
          'onemli_mi': data['onemli_mi'] ?? false,
          'not_id': notId,
        },
      );
      return true;
    } catch (e) {
      print('Error updating hayvan not: $e');
      return false;
    }
  }

  Future<bool> deleteHayvanNot(int notId) async {
    try {
      await execute(
        'DELETE FROM hayvan_not WHERE not_id = ?',
        substitutionValues: {'not_id': notId},
      );
      return true;
    } catch (e) {
      print('Error deleting hayvan not: $e');
      return false;
    }
  }

  // KULLANICI AYARLARI İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getKullaniciAyarlari(
      int kullaniciId) async {
    final sql = '''
      SELECT * FROM kullanici_ayar 
      WHERE kullanici_id = @kullanici_id
    ''';

    return await query(sql, substitutionValues: {'kullanici_id': kullaniciId});
  }

  Future<Map<String, dynamic>> getKullaniciAyar(
      int kullaniciId, String ayarTipi) async {
    final sql = '''
      SELECT * FROM kullanici_ayar 
      WHERE kullanici_id = @kullanici_id AND ayar_tipi = @ayar_tipi
      LIMIT 1
    ''';

    final results = await query(sql, substitutionValues: {
      'kullanici_id': kullaniciId,
      'ayar_tipi': ayarTipi,
    });

    return results.isNotEmpty ? results.first : {};
  }

  Future<bool> setKullaniciAyar(Map<String, dynamic> data) async {
    // Önce ayarın var olup olmadığını kontrol et
    final checkSql = '''
      SELECT ayar_id FROM kullanici_ayar 
      WHERE kullanici_id = @kullanici_id AND ayar_tipi = @ayar_tipi
      LIMIT 1
    ''';

    final results = await query(checkSql, substitutionValues: {
      'kullanici_id': data['kullanici_id'],
      'ayar_tipi': data['ayar_tipi'],
    });

    if (results.isNotEmpty) {
      // Güncelleme
      final updateSql = '''
        UPDATE kullanici_ayar SET
          ayar_deger = @ayar_deger
        WHERE kullanici_id = @kullanici_id AND ayar_tipi = @ayar_tipi
      ''';

      return await execute(updateSql, substitutionValues: {
        'kullanici_id': data['kullanici_id'],
        'ayar_tipi': data['ayar_tipi'],
        'ayar_deger': data['ayar_deger'],
      });
    } else {
      // Ekleme
      final insertSql = '''
        INSERT INTO kullanici_ayar (
          kullanici_id, ayar_tipi, ayar_deger
        ) VALUES (
          @kullanici_id, @ayar_tipi, @ayar_deger
        )
      ''';

      return await execute(insertSql, substitutionValues: {
        'kullanici_id': data['kullanici_id'],
        'ayar_tipi': data['ayar_tipi'],
        'ayar_deger': data['ayar_deger'],
      });
    }
  }

  // BİLDİRİM İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getBildirimler(
    int kullaniciId, {
    bool sadeceOkunmamis = false,
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
  }) async {
    String sql = '''
      SELECT * FROM bildirim 
      WHERE kullanici_id = @kullanici_id
    ''';

    Map<String, dynamic> params = {'kullanici_id': kullaniciId};

    if (sadeceOkunmamis) {
      sql += ' AND okundu_mu = false';
    }

    if (baslangicTarihi != null) {
      sql += ' AND created_at >= @baslangic_tarihi';
      params['baslangic_tarihi'] = baslangicTarihi.toIso8601String();
    }

    if (bitisTarihi != null) {
      sql += ' AND created_at <= @bitis_tarihi';
      params['bitis_tarihi'] = bitisTarihi.toIso8601String();
    }

    sql += ' ORDER BY created_at DESC';

    return await query(sql, substitutionValues: params);
  }

  Future<bool> addBildirim(Map<String, dynamic> data) async {
    final sql = '''
      INSERT INTO bildirim (
        kullanici_id, baslik, icerik, bildirim_tipi, 
        ilgili_kayit_id, ilgili_tablo, okundu_mu
      ) VALUES (
        @kullanici_id, @baslik, @icerik, @bildirim_tipi, 
        @ilgili_kayit_id, @ilgili_tablo, false
      )
    ''';

    return await execute(sql, substitutionValues: {
      'kullanici_id': data['kullanici_id'],
      'baslik': data['baslik'],
      'icerik': data['icerik'],
      'bildirim_tipi': data['bildirim_tipi'],
      'ilgili_kayit_id': data['ilgili_kayit_id'],
      'ilgili_tablo': data['ilgili_tablo'],
    });
  }

  Future<bool> bildirimOkundu(int bildirimId) async {
    final sql = '''
      UPDATE bildirim SET
        okundu_mu = true,
        goruldu_tarihi = NOW()
      WHERE bildirim_id = @bildirim_id
    ''';

    return await execute(sql, substitutionValues: {'bildirim_id': bildirimId});
  }

  Future<bool> tumBildirimleriOkunduYap(int kullaniciId) async {
    final sql = '''
      UPDATE bildirim SET
        okundu_mu = true,
        goruldu_tarihi = NOW()
      WHERE kullanici_id = @kullanici_id AND okundu_mu = false
    ''';

    return await execute(sql,
        substitutionValues: {'kullanici_id': kullaniciId});
  }

  // GÜNLÜK AKTİVİTE İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getGunlukAktiviteler({
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    String? aktiviteTipi,
    int? kullaniciId,
    String? durum,
  }) async {
    String sql = 'SELECT * FROM gunluk_aktivite WHERE 1=1';
    Map<String, dynamic> params = {};

    if (baslangicTarihi != null) {
      sql += ' AND baslangic_zamani >= @baslangic_tarihi';
      params['baslangic_tarihi'] = baslangicTarihi.toIso8601String();
    }

    if (bitisTarihi != null) {
      sql += ' AND baslangic_zamani <= @bitis_tarihi';
      params['bitis_tarihi'] = bitisTarihi.toIso8601String();
    }

    if (aktiviteTipi != null) {
      sql += ' AND aktivite_tipi = @aktivite_tipi';
      params['aktivite_tipi'] = aktiviteTipi;
    }

    if (kullaniciId != null) {
      sql += ' AND kullanici_id = @kullanici_id';
      params['kullanici_id'] = kullaniciId;
    }

    if (durum != null) {
      sql += ' AND durum = @durum';
      params['durum'] = durum;
    }

    sql += ' ORDER BY baslangic_zamani DESC';

    return await query(sql, substitutionValues: params);
  }

  Future<bool> addGunlukAktivite(Map<String, dynamic> data) async {
    final sql = '''
      INSERT INTO gunluk_aktivite (
        aktivite_tipi, aciklama, baslangic_zamani, bitis_zamani,
        durum, kullanici_id, ilgili_hayvan_id, ilgili_suru_id, konum_bilgisi
      ) VALUES (
        @aktivite_tipi, @aciklama, @baslangic_zamani, @bitis_zamani,
        @durum, @kullanici_id, @ilgili_hayvan_id, @ilgili_suru_id, @konum_bilgisi
      )
    ''';

    return await execute(sql, substitutionValues: {
      'aktivite_tipi': data['aktivite_tipi'],
      'aciklama': data['aciklama'],
      'baslangic_zamani': data['baslangic_zamani'],
      'bitis_zamani': data['bitis_zamani'],
      'durum': data['durum'] ?? 'planlandı',
      'kullanici_id': data['kullanici_id'],
      'ilgili_hayvan_id': data['ilgili_hayvan_id'],
      'ilgili_suru_id': data['ilgili_suru_id'],
      'konum_bilgisi': data['konum_bilgisi'],
    });
  }

  Future<bool> updateAktiviteDurum(int aktiviteId, String yeniDurum) async {
    final sql = '''
      UPDATE gunluk_aktivite SET
        durum = @durum
      WHERE aktivite_id = @aktivite_id
    ''';

    return await execute(sql, substitutionValues: {
      'aktivite_id': aktiviteId,
      'durum': yeniDurum,
    });
  }

  Future<bool> tamamlaAktivite(int aktiviteId, DateTime bitisTarihi) async {
    final sql = '''
      UPDATE gunluk_aktivite SET
        durum = 'tamamlandı',
        bitis_zamani = @bitis_zamani
      WHERE aktivite_id = @aktivite_id
    ''';

    return await execute(sql, substitutionValues: {
      'aktivite_id': aktiviteId,
      'bitis_zamani': bitisTarihi.toIso8601String(),
    });
  }

  // Toplam tartım sayısını getirir
  Future<int> getWeightMeasurementCount() async {
    try {
      final result =
          await query('SELECT COUNT(*) as count FROM weight_measurements');
      return result.first['count'] as int;
    } catch (e) {
      print('Tartım sayma hatası: $e');
      return 0;
    }
  }

  // Stabil tartım sayısını getirir
  Future<int> getStableWeightMeasurementCount() async {
    try {
      final result = await query(
          'SELECT COUNT(*) as count FROM weight_measurements WHERE is_stable = 1');
      return result.first['count'] as int;
    } catch (e) {
      print('Stabil tartım sayma hatası: $e');
      return 0;
    }
  }

  // Ortalama ağırlığı getirir
  Future<double?> getAverageWeight() async {
    try {
      final result = await query(
          'SELECT AVG(weight) as average FROM weight_measurements WHERE is_stable = 1');
      final average = result.first['average'];
      if (average == null) return null;
      return average is int ? average.toDouble() : average as double;
    } catch (e) {
      print('Ortalama ağırlık hesaplama hatası: $e');
      return null;
    }
  }

  // Veritabanındaki tablo isimlerini döndürür
  Future<List<String>> getTableNames() async {
    try {
      final result = await query(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");
      return result.map((row) => row['name'] as String).toList();
    } catch (e) {
      print('Tablo isimleri getirme hatası: $e');
      return ['hayvanlar', 'weight_measurements', 'health_records', 'tasks'];
    }
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      final result = await db.rawQuery(sql, arguments);
      return result.map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (e) {
      print('Database query error: $e');
      return [];
    }
  }

  Future<void> rawExecute(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      await db.execute(sql, arguments);
    } catch (e) {
      print('Database execute error: $e');
      throw e;
    }
  }

  Future<int> insertRecord(String tableName, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.insert(tableName, data);
    } catch (e) {
      print('Database insert error: $e');
      throw e;
    }
  }

  Future<int> updateRecord(String tableName, Map<String, dynamic> data,
      {String? where, List<dynamic>? whereArgs}) async {
    try {
      final db = await database;
      return await db.update(tableName, data,
          where: where, whereArgs: whereArgs);
    } catch (e) {
      print('Database update error: $e');
      throw e;
    }
  }

  Future<int> deleteRecord(String tableName,
      {String? where, List<dynamic>? whereArgs}) async {
    try {
      final db = await database;
      return await db.delete(tableName, where: where, whereArgs: whereArgs);
    } catch (e) {
      print('Database delete error: $e');
      throw e;
    }
  }
}

// Cache entry class for in-memory caching
class _CacheEntry {
  final List<Map<String, dynamic>> data;
  final DateTime expiryTime;

  _CacheEntry(this.data, Duration duration)
      : expiryTime = DateTime.now().add(duration);

  bool isExpired() {
    return DateTime.now().isAfter(expiryTime);
  }
}
