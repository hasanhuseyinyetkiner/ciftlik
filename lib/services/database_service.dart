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
        if (_connection != null) {
          _isConnected = true;
          print('Database connection established successfully');
          return;
        } else {
          // Connection is null, likely in offline mode
          print('Database connection is null, operating in offline mode');
          _isConnected = false;
          return;
        }
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

  // Check connection status
  Future<bool> checkConnection() async {
    if (_isConnected && _connection != null) {
      try {
        // Test query to verify connection
        await _connection!.query('SELECT 1');
        return true;
      } catch (e) {
        _isConnected = false;
        return false;
      }
    }
    return false;
  }

  // Set offline mode
  void setOfflineMode(bool value) {
    _dbConfig.setOfflineMode(value);
    _isConnected = !value;
  }

  // HAYVAN NOT İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getHayvanNotlari(int hayvanId) async {
    final sql = '''
      SELECT * FROM hayvan_not 
      WHERE hayvan_id = @hayvan_id
      ORDER BY created_at DESC
    ''';

    return await query(sql, substitutionValues: {'hayvan_id': hayvanId});
  }

  Future<bool> addHayvanNot(Map<String, dynamic> data) async {
    final sql = '''
      INSERT INTO hayvan_not (
        hayvan_id, not_metni, kullanici_id, onemli_mi
      ) VALUES (
        @hayvan_id, @not_metni, @kullanici_id, @onemli_mi
      )
    ''';

    return await execute(sql, substitutionValues: {
      'hayvan_id': data['hayvan_id'],
      'not_metni': data['not_metni'],
      'kullanici_id': data['kullanici_id'],
      'onemli_mi': data['onemli_mi'] ?? false,
    });
  }

  Future<bool> updateHayvanNot(int notId, Map<String, dynamic> data) async {
    final sql = '''
      UPDATE hayvan_not SET
        not_metni = @not_metni,
        onemli_mi = @onemli_mi
      WHERE not_id = @not_id
    ''';

    return await execute(sql, substitutionValues: {
      'not_id': notId,
      'not_metni': data['not_metni'],
      'onemli_mi': data['onemli_mi'] ?? false,
    });
  }

  Future<bool> deleteHayvanNot(int notId) async {
    final sql = 'DELETE FROM hayvan_not WHERE not_id = @not_id';
    return await execute(sql, substitutionValues: {'not_id': notId});
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
}
