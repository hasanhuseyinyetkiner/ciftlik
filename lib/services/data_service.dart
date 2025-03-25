import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../adapter.dart';
import 'database_service.dart';
import 'api_service.dart';
import '../services/supabase_rest_service.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ApiService _apiService = Get.find<ApiService>();
  late final SupabaseAdapter _supabaseAdapter = Get.find<SupabaseAdapter>();
  final SupabaseRestService _supabaseService = SupabaseRestService();

  bool _isOfflineMode = false;
  bool _isInitialized = false;
  bool _useSupabase = true; // Supabase'i aktif ediyoruz
  bool _syncInProgress = false;

  final RxBool _isInitializedRx = false.obs;
  final RxBool _isOnline = false.obs;
  final RxBool _isUsingSupabase = true.obs;
  late SupabaseClient _supabase;
  late http.Client _httpClient;

  Timer? _syncTimer;
  final _pendingSync = <String, List<Map<String, dynamic>>>{}.obs;

  final String _apiBaseUrl = 'https://api.ciftlikyonetim.com/v1';

  bool get isInitialized => _isInitializedRx.value;
  bool get isOnline => _isOnline.value;
  bool get isUsingSupabase => _isUsingSupabase.value;
  bool get isOffline => _isOfflineMode;

  // Initialize services
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize all services
    await _dbService.init();
    await _supabaseService.init();
    await _checkConnectionStatus();
    _isInitialized = true;

    // Check if we need to sync data
    if (!_isOfflineMode && _useSupabase) {
      _scheduleSyncData();
    }
  }

  // Check connection status to determine if we should use offline mode
  Future<void> _checkConnectionStatus() async {
    try {
      // First check Supabase connection
      bool supabaseConnected = false;
      if (_useSupabase) {
        supabaseConnected = await _supabaseService.checkConnection();
      }

      if (supabaseConnected) {
        print(
            'Supabase connection available, using Supabase as primary data source.');
        _setOfflineMode(false);
        _useSupabase = true;
        return;
      }

      // If Supabase is not available, check database connection
      bool dbConnected = await _dbService.checkConnection();

      if (!dbConnected) {
        print('All connections unavailable, switching to offline mode.');
        _setOfflineMode(true);
        return;
      }

      // Check API connection with a simple request
      final prefs = await SharedPreferences.getInstance();
      bool apiAvailable = prefs.getBool('api_available') ?? false;

      // If API was previously unavailable, we'll stay in last known state
      // Otherwise, we'll attempt to connect
      if (!apiAvailable) {
        print('API was previously unavailable, staying in offline mode.');
        _setOfflineMode(true);
      } else {
        _setOfflineMode(false);
        _useSupabase = false;
      }
    } catch (e) {
      print('Error checking connection status: $e');
      _setOfflineMode(true);
    }
  }

  // Set offline mode for all services
  void _setOfflineMode(bool value) {
    _isOfflineMode = value;
    _dbService.setOfflineMode(value);
    _apiService.setOfflineMode(value);
    _supabaseService.setOfflineMode(value);
  }

  // Supabase connection check
  bool _isSupabaseConnected() {
    return _useSupabase && !_isOfflineMode;
  }

  // Switch to offline mode manually
  Future<void> switchToOfflineMode(bool value) async {
    _setOfflineMode(value);

    // Remember API availability status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('api_available', !value);

    // If switching back online and Supabase is enabled, try to sync data
    if (!value && _useSupabase) {
      _scheduleSyncData();
    }
  }

  // Schedule data sync to avoid blocking the UI
  void _scheduleSyncData() {
    Future.delayed(Duration(seconds: 1), () {
      syncDataWithSupabase();
    });
  }

  // Sync local database with Supabase
  Future<bool> syncDataWithSupabase() async {
    if (_syncInProgress || _isOfflineMode || !_useSupabase) {
      return false;
    }

    _syncInProgress = true;
    bool success = true;

    try {
      print('Starting data sync with Supabase...');

      // Sync base tables
      await _syncTable('hayvanlar', 'id');
      await _syncTable('hayvan_not', 'id');
      await _syncTable('kullanici_ayar', 'ayar_id');
      await _syncTable('bildirim', 'id');
      await _syncTable('gunluk_aktivite', 'id');

      // Sync weight and measurement tables
      await _syncTable('tartim', 'id');
      await _syncTable('agirlik_olcum', 'id');
      await _syncTable('bluetooth_olcum', 'id');

      // Sync milk production tables
      await _syncTable('sut_uretim', 'id');
      await _syncTable('sut_kalite', 'id');

      // Sync health-related tables
      await _syncTable('asi_kayitlari', 'id');
      await _syncTable('hastalik_kayitlari', 'id');
      await _syncTable('tedavi_kayitlari', 'id');

      print('Data sync with Supabase completed successfully.');
    } catch (e) {
      print('Error during data sync with Supabase: $e');
      success = false;
    } finally {
      _syncInProgress = false;
    }

    return success;
  }

  // Sync specific table between local DB and Supabase
  Future<void> _syncTable(String tableName, String idColumn) async {
    try {
      print('Syncing table: $tableName');

      // Get local data
      final localData = await _dbService.query('SELECT * FROM $tableName');

      // Get Supabase data
      final supabaseData = await _supabaseService.getData(tableName);

      if (supabaseData == null) {
        print('No data received from Supabase for $tableName');
        return;
      }

      // Create maps for easier comparison
      final localMap = {
        for (var item in localData) item[idColumn].toString(): item
      };
      final supabaseMap = {
        for (var item in supabaseData) item[idColumn].toString(): item
      };

      // Items to insert in Supabase (exists locally but not in Supabase)
      final itemsToInsert = localData
          .where(
              (local) => !supabaseMap.containsKey(local[idColumn].toString()))
          .toList();

      // Items to update in local DB (exists in both but Supabase is newer)
      // This assumes both have a 'updated_at' field for comparison
      final itemsToUpdateLocal = [];
      for (final entry in supabaseMap.entries) {
        if (localMap.containsKey(entry.key)) {
          final supabaseItem = entry.value;
          final localItem = localMap[entry.key]!;

          // Compare updated_at dates if available
          if (supabaseItem.containsKey('updated_at') &&
              localItem.containsKey('updated_at')) {
            final supabaseDate = DateTime.parse(supabaseItem['updated_at']);
            final localDate = localItem['updated_at'] is String
                ? DateTime.parse(localItem['updated_at'])
                : localItem['updated_at'];

            if (supabaseDate.isAfter(localDate)) {
              itemsToUpdateLocal.add(supabaseItem);
            }
          }
        } else {
          // Item exists in Supabase but not locally, add to local DB
          itemsToUpdateLocal.add(entry.value);
        }
      }

      // Perform inserts to Supabase
      for (var item in itemsToInsert) {
        await _supabaseService.insertData(tableName, item);
      }

      // Perform updates to local DB
      for (var item in itemsToUpdateLocal) {
        // Create SQL for update or insert
        if (localMap.containsKey(item[idColumn].toString())) {
          // Update
          final setClause = item.entries
              .where((e) => e.key != idColumn)
              .map((e) => '"${e.key}" = @${e.key}')
              .join(', ');

          final sql =
              'UPDATE "$tableName" SET $setClause WHERE "$idColumn" = @$idColumn';
          await _dbService.execute(sql, substitutionValues: item);
        } else {
          // Insert
          final columns = item.keys.map((k) => '"$k"').join(', ');
          final values = item.keys.map((k) => '@$k').join(', ');
          final sql = 'INSERT INTO "$tableName" ($columns) VALUES ($values)';
          await _dbService.execute(sql, substitutionValues: item);
        }
      }

      print(
          'Synced $tableName: Inserted ${itemsToInsert.length} items to Supabase, Updated ${itemsToUpdateLocal.length} items locally');
    } catch (e) {
      print('Error syncing table $tableName: $e');
    }
  }

  // Public method to force sync after user interactions
  Future<bool> syncAfterUserInteraction({List<String>? specificTables}) async {
    if (_isOfflineMode || !_useSupabase) {
      print(
          'Cannot sync: offline mode is $_isOfflineMode, useSupabase is $_useSupabase');
      return false;
    }

    // If specific tables are provided, sync only those
    if (specificTables != null && specificTables.isNotEmpty) {
      _syncInProgress = true;
      bool success = true;

      try {
        print('Starting sync for specific tables after user interaction...');

        for (final table in specificTables) {
          String idColumn = 'id';
          if (table == 'kullanici_ayar') idColumn = 'ayar_id';
          await _syncTable(table, idColumn);
        }

        print('Sync after user interaction completed successfully.');
      } catch (e) {
        print('Error during sync after user interaction: $e');
        _syncInProgress = false;
        return false;
      }

      return true;
    }

    // Otherwise sync all tables
    return syncDataWithSupabase();
  }

  // Generic method to fetch data with automatic fallback to database
  Future<List<Map<String, dynamic>>> fetchData({
    required String apiEndpoint,
    required String tableName,
    Map<String, dynamic>? queryParams,
    String? whereClause,
    Map<String, dynamic>? substitutionValues,
    String? column,
    dynamic value,
  }) async {
    await init();

    try {
      if (isUsingSupabase) {
        // Adaptör üzerinden veri çekme
        print('Fetching data from Supabase: $tableName');

        switch (tableName) {
          case 'hayvanlar':
            return await _supabaseAdapter.getHayvanlar();
          case 'hayvan_not':
            // Bu tabloyu henüz desteklemiyoruz, yerel veritabanına düşecek
            break;
          case 'asi_kayitlari':
            return await _supabaseAdapter.getAsiKayitlari();
          case 'sut_uretim':
            return await _supabaseAdapter.getSutUretim();
          default:
            // Desteklenmeyen tablo, yerel veritabanına düşecek
            break;
        }
      }

      // Eğer Supabase çalışmazsa veya tablo desteklenmiyorsa yerel veritabanına düş
      return _fetchFromLocalDatabase(
        tableName: tableName,
        whereClause: whereClause,
        substitutionValues: substitutionValues,
        column: column,
        value: value,
      );
    } catch (e) {
      print('Error fetching data from Supabase: $e');
      print('Falling back to local database');

      // Supabase'den veri çekmeyi denedik ama hata aldık, yerel veritabanına düşelim
      return _fetchFromLocalDatabase(
        tableName: tableName,
        whereClause: whereClause,
        substitutionValues: substitutionValues,
        column: column,
        value: value,
      );
    }
  }

  // Yerel veritabanından veri çekme
  Future<List<Map<String, dynamic>>> _fetchFromLocalDatabase({
    required String tableName,
    String? whereClause,
    Map<String, dynamic>? substitutionValues,
    String? column,
    dynamic value,
  }) async {
    try {
      String query;

      if (column != null && value != null) {
        query = 'SELECT * FROM $tableName WHERE $column = @value';
        return await _dbService
            .query(query, substitutionValues: {'value': value});
      } else if (whereClause != null) {
        query = 'SELECT * FROM $tableName WHERE $whereClause';
        return await _dbService.query(query,
            substitutionValues: substitutionValues);
      } else {
        query = 'SELECT * FROM $tableName';
        return await _dbService.query(query);
      }
    } catch (e) {
      print('Error fetching from local database: $e');
      return [];
    }
  }

  // Generic method to save data (insert or update)
  Future<bool> saveData({
    required String apiEndpoint,
    required String tableName,
    required Map<String, dynamic> data,
    bool isUpdate = false,
    String? primaryKeyField,
    dynamic primaryKeyValue,
    String? idColumn,
  }) async {
    await init();

    try {
      if (isUsingSupabase) {
        print('Saving data to Supabase: $tableName');

        if (isUpdate && primaryKeyField != null && primaryKeyValue != null) {
          // Update existing record
          switch (tableName) {
            case 'hayvanlar':
              final result = await _supabaseAdapter.updateHayvan(
                  primaryKeyValue.toString(), data);
              return result != null;
            // Diğer tablolar için güncelleme metotları buraya eklenebilir
            default:
              // Desteklenmeyen tablo, yerel veritabanına düşecek
              break;
          }
        } else {
          // Insert new record
          switch (tableName) {
            case 'hayvanlar':
              final result = await _supabaseAdapter.addHayvan(data);
              return result.isNotEmpty;
            case 'asi_kayitlari':
              final result = await _supabaseAdapter.addAsiKaydi(data);
              return result != null;
            case 'sut_uretim':
              final result = await _supabaseAdapter.addSutUretim(data);
              return result != null;
            default:
              // Desteklenmeyen tablo, yerel veritabanına düşecek
              break;
          }
        }
      }

      // Eğer Supabase çalışmazsa veya tablo desteklenmiyorsa yerel veritabanına düş
      return _saveToLocalDatabase(
        tableName: tableName,
        data: data,
        isUpdate: isUpdate,
        primaryKeyField: primaryKeyField,
        primaryKeyValue: primaryKeyValue,
      );
    } catch (e) {
      print('Error saving data to Supabase: $e');
      print('Falling back to local database');

      // Supabase'e veri kaydetmeyi denedik ama hata aldık, yerel veritabanına düşelim
      return _saveToLocalDatabase(
        tableName: tableName,
        data: data,
        isUpdate: isUpdate,
        primaryKeyField: primaryKeyField,
        primaryKeyValue: primaryKeyValue,
      );
    }
  }

  // Yerel veritabanına veri kaydetme
  Future<bool> _saveToLocalDatabase({
    required String tableName,
    required Map<String, dynamic> data,
    bool isUpdate = false,
    String? primaryKeyField,
    dynamic primaryKeyValue,
  }) async {
    try {
      if (isUpdate && primaryKeyField != null && primaryKeyValue != null) {
        // Update existing record
        final setClause =
            data.entries.map((e) => '"${e.key}" = @${e.key}').join(', ');

        final query =
            'UPDATE "$tableName" SET $setClause WHERE "$primaryKeyField" = @primaryKeyValue';

        final values = Map<String, dynamic>.from(data);
        values['primaryKeyValue'] = primaryKeyValue;

        await _dbService.execute(query, substitutionValues: values);
        return true;
      } else {
        // Insert new record
        final columns = data.keys.map((k) => '"$k"').join(', ');
        final placeholders = data.keys.map((k) => '@$k').join(', ');

        final query =
            'INSERT INTO "$tableName" ($columns) VALUES ($placeholders)';

        await _dbService.execute(query, substitutionValues: data);
        return true;
      }
    } catch (e) {
      print('Error saving to local database: $e');
      return false;
    }
  }

  // Generic method to delete data
  Future<bool> deleteData({
    required String apiEndpoint,
    required String tableName,
    required dynamic id,
    String idColumn = 'id',
  }) async {
    await init();

    try {
      if (isUsingSupabase) {
        print('Deleting data from Supabase: $tableName, ID: $id');

        switch (tableName) {
          case 'hayvanlar':
            return await _supabaseAdapter.deleteHayvan(id.toString());
          // Diğer tablolar için silme metotları buraya eklenebilir
          default:
            // Desteklenmeyen tablo, yerel veritabanına düşecek
            break;
        }
      }

      // Eğer Supabase çalışmazsa veya tablo desteklenmiyorsa yerel veritabanına düş
      return _deleteFromLocalDatabase(
        tableName: tableName,
        id: id,
        idColumn: idColumn,
      );
    } catch (e) {
      print('Error deleting data from Supabase: $e');
      print('Falling back to local database');

      // Supabase'den veri silmeyi denedik ama hata aldık, yerel veritabanına düşelim
      return _deleteFromLocalDatabase(
        tableName: tableName,
        id: id,
        idColumn: idColumn,
      );
    }
  }

  // Yerel veritabanından veri silme
  Future<bool> _deleteFromLocalDatabase({
    required String tableName,
    required dynamic id,
    String idColumn = 'id',
  }) async {
    try {
      final query = 'DELETE FROM "$tableName" WHERE "$idColumn" = @id';
      await _dbService.execute(query, substitutionValues: {'id': id});
      return true;
    } catch (e) {
      print('Error deleting from local database: $e');
      return false;
    }
  }

  // Execute a custom query using Supabase RPC
  Future<List<Map<String, dynamic>>> executeCustomQuery({
    required String functionName,
    Map<String, dynamic>? params,
    String? fallbackSql,
    Map<String, dynamic>? substitutionValues,
  }) async {
    await init();

    if (!_isOfflineMode && _useSupabase) {
      try {
        // Try to execute the function in Supabase
        final result = await _supabaseService.executeRawQuery(
          functionName,
          substitutionValues: params,
        );

        if (result != null) {
          return result;
        }
        // If Supabase fails, fall back to legacy API or database
        _useSupabase = false;
      } catch (e) {
        print('Supabase RPC error: $e');
        _useSupabase = false;
      }
    }

    // If Supabase failed or is not available, try using the local database
    if (fallbackSql != null) {
      return await _dbService.query(fallbackSql,
          substitutionValues: substitutionValues);
    }

    // If no fallback SQL provided, return empty list
    return [];
  }

  // SPECIFIC ENTITY METHODS FOLLOW
  // These methods use the generic methods above but provide specific
  // endpoints and table names for each entity type

  // HAYVAN NOT İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getHayvanNotlari(int hayvanId) async {
    await init();

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final response = await _supabaseService.supabase
            .from('hayvan_not')
            .select()
            .eq('hayvan_id', hayvanId)
            .order('created_at', ascending: false);

        if (response != null && response.isNotEmpty) {
          return List<Map<String, dynamic>>.from(response);
        } else {
          // API'den veri gelmezse veritabanına geç
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API hayvan notları alınırken hata: $e');
        _setOfflineMode(true);
      }
    }

    // Veritabanından al
    return await _dbService.getHayvanNotlari(hayvanId);
  }

  Future<bool> addHayvanNot(Map<String, dynamic> data) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final response = await _supabaseService.insertData('hayvan_not', data);
        success = response != null;

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API hayvan notu eklenirken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.addHayvanNot(data);
    }

    return success;
  }

  Future<bool> updateHayvanNot(int notId, Map<String, dynamic> data) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final response =
            await _supabaseService.updateData('hayvan_not', notId, data);
        success = response != null;

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API hayvan notu güncellenirken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.updateHayvanNot(notId, data);
    }

    return success;
  }

  Future<bool> deleteHayvanNot(int notId) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        success = await _supabaseService.deleteData('hayvan_not', notId);

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API hayvan notu silinirken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.deleteHayvanNot(notId);
    }

    return success;
  }

  // KULLANICI AYARLARI İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getKullaniciAyarlari(
      int kullaniciId) async {
    await init();

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final response = await _supabaseService.supabase
            .from('kullanici_ayar')
            .select()
            .eq('kullanici_id', kullaniciId);

        if (response != null && response.isNotEmpty) {
          return List<Map<String, dynamic>>.from(response);
        } else {
          // API'den veri gelmezse veritabanına geç
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API kullanıcı ayarları alınırken hata: $e');
        _setOfflineMode(true);
      }
    }

    // Veritabanından al
    return await _dbService.getKullaniciAyarlari(kullaniciId);
  }

  Future<Map<String, dynamic>> getKullaniciAyar(
      int kullaniciId, String ayarTipi) async {
    await init();

    final ayarlar = await getKullaniciAyarlari(kullaniciId);

    for (var ayar in ayarlar) {
      if (ayar['ayar_tipi'] == ayarTipi) {
        return ayar;
      }
    }

    return {};
  }

  Future<bool> setKullaniciAyar(Map<String, dynamic> data) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Check if setting exists
        final response = await _supabaseService.supabase
            .from('kullanici_ayar')
            .select()
            .eq('kullanici_id', data['kullanici_id'])
            .eq('ayar_tipi', data['ayar_tipi'])
            .maybeSingle();

        if (response != null) {
          // Update existing setting
          final updateResponse = await _supabaseService.updateData(
              'kullanici_ayar', response['ayar_id'], data);
          success = updateResponse != null;
        } else {
          // Insert new setting
          final insertResponse =
              await _supabaseService.insertData('kullanici_ayar', data);
          success = insertResponse != null;
        }

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API kullanıcı ayarı güncellenirken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.setKullaniciAyar(data);
    }

    return success;
  }

  // BİLDİRİM İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getBildirimler(
    int kullaniciId, {
    bool sadeceOkunmamis = false,
    bool sadeceMevcutHafta = false,
  }) async {
    await init();

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        var query = _supabaseService.supabase
            .from('bildirim')
            .select()
            .eq('kullanici_id', kullaniciId);

        if (sadeceOkunmamis) {
          query = query.eq('okundu_mu', false);
        }

        if (sadeceMevcutHafta) {
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          query = query.gte('created_at', startOfWeek.toIso8601String());
        }

        final response = await query.order('created_at', ascending: false);

        if (response != null && response.isNotEmpty) {
          return List<Map<String, dynamic>>.from(response);
        } else {
          // API'den veri gelmezse veritabanına geç
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API bildirimler alınırken hata: $e');
        _setOfflineMode(true);
      }
    }

    // Veritabanından al
    DateTime? baslangicTarihi;
    if (sadeceMevcutHafta) {
      final now = DateTime.now();
      baslangicTarihi = now.subtract(Duration(days: now.weekday - 1));
    }

    return await _dbService.getBildirimler(
      kullaniciId,
      sadeceOkunmamis: sadeceOkunmamis,
      baslangicTarihi: baslangicTarihi,
    );
  }

  Future<bool> addBildirim(Map<String, dynamic> data) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final response = await _supabaseService.insertData('bildirim', data);
        success = response != null;

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API bildirim oluşturulurken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.addBildirim(data);
    }

    return success;
  }

  Future<bool> bildirimOkundu(int bildirimId) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final updateData = {
          'okundu_mu': true,
          'goruldu_tarihi': DateTime.now().toIso8601String()
        };

        final response = await _supabaseService.updateData(
            'bildirim', bildirimId, updateData);

        success = response != null;
      } catch (e) {
        print('API bildirim okundu işaretlenirken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.bildirimOkundu(bildirimId);
    }

    return success;
  }

  Future<bool> tumBildirimleriOkunduYap(int kullaniciId) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Using Supabase RPC for bulk update
        await _supabaseService.supabase.rpc('tum_bildirimleri_okundu_yap',
            params: {'p_kullanici_id': kullaniciId});
        success = true;
      } catch (e) {
        print('API tüm bildirimler okundu işaretlenirken hata: $e');
        _setOfflineMode(true);
      }
    }

    return await _dbService.tumBildirimleriOkunduYap(kullaniciId);
  }

  // GÜNLÜK AKTİVİTE İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getGunlukAktiviteler({
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    String? aktiviteTipi,
    int? kullaniciId,
    String? durum,
  }) async {
    await init();

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        var query = _supabaseService.supabase.from('gunluk_aktivite').select();

        if (baslangicTarihi != null) {
          query =
              query.gte('baslangic_zamani', baslangicTarihi.toIso8601String());
        }

        if (bitisTarihi != null) {
          query = query.lte('baslangic_zamani', bitisTarihi.toIso8601String());
        }

        if (aktiviteTipi != null) {
          query = query.eq('aktivite_tipi', aktiviteTipi);
        }

        if (kullaniciId != null) {
          query = query.eq('kullanici_id', kullaniciId);
        }

        if (durum != null) {
          query = query.eq('durum', durum);
        }

        final response =
            await query.order('baslangic_zamani', ascending: false);

        if (response != null && response.isNotEmpty) {
          return List<Map<String, dynamic>>.from(response);
        } else {
          // API'den veri gelmezse veritabanına geç
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API günlük aktiviteler alınırken hata: $e');
        _setOfflineMode(true);
      }
    }

    // Veritabanından al
    return await _dbService.getGunlukAktiviteler(
      baslangicTarihi: baslangicTarihi,
      bitisTarihi: bitisTarihi,
      aktiviteTipi: aktiviteTipi,
      kullaniciId: kullaniciId,
      durum: durum,
    );
  }

  Future<bool> addGunlukAktivite(Map<String, dynamic> data) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final response =
            await _supabaseService.insertData('gunluk_aktivite', data);
        success = response != null;

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API günlük aktivite oluşturulurken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.addGunlukAktivite(data);
    }

    return success;
  }

  Future<bool> updateAktiviteDurum(int aktiviteId, String yeniDurum) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final updateData = {'durum': yeniDurum};
        final response = await _supabaseService.updateData(
            'gunluk_aktivite', aktiviteId, updateData);
        success = response != null;

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API aktivite durumu güncellenirken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.updateAktiviteDurum(aktiviteId, yeniDurum);
    }

    return success;
  }

  Future<bool> tamamlaAktivite(int aktiviteId) async {
    await init();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Use Supabase instead of ApiService
        final now = DateTime.now();
        final updateData = {
          'durum': 'tamamlandı',
          'bitis_zamani': now.toIso8601String()
        };

        final response = await _supabaseService.updateData(
            'gunluk_aktivite', aktiviteId, updateData);
        success = response != null;

        if (!success) {
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API aktivite tamamlanırken hata: $e');
        _setOfflineMode(true);
      }
    }

    if (_isOfflineMode || !success) {
      return await _dbService.tamamlaAktivite(aktiviteId, DateTime.now());
    }

    return success;
  }

  Future<void> _initialize() async {
    try {
      // Initialize Supabase client
      _supabase = Supabase.instance.client;
      _httpClient = http.Client();

      // Check connection
      _checkConnection();

      // Set up connection listener
      Connectivity().onConnectivityChanged.listen(_processConnectivityResult);

      // Set up periodic sync
      _setupPeriodicSync();

      _isInitializedRx.value = true;
    } catch (e) {
      print('Error initializing DataService: $e');
      _isInitializedRx.value = false;
    }
  }

  void _checkConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _processConnectivityResult(result);
    } catch (e) {
      _isOnline.value = false;
      print('Error checking connectivity: $e');
    }
  }

  void _processConnectivityResult(dynamic result) {
    bool hasConnection = false;

    if (result is List<ConnectivityResult>) {
      // Handle list of results (newer versions of connectivity_plus)
      hasConnection = result.any((r) => r != ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      // Handle single result (older versions of connectivity_plus)
      hasConnection = result != ConnectivityResult.none;
    }

    // Update the RxBool value
    _isOnline.value = hasConnection;

    // Try to sync when we get back online
    if (hasConnection) {
      _syncPendingData();
    }
  }

  void _setupPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 15), (timer) {
      if (_isOnline.value) {
        _syncPendingData();
      }
    });
  }

  Future<void> _syncPendingData() async {
    if (!_isOnline.value || _pendingSync.isEmpty) return;

    final tables = _pendingSync.keys.toList();
    for (final table in tables) {
      final pendingRecords = _pendingSync[table] ?? [];
      if (pendingRecords.isEmpty) continue;

      for (int i = 0; i < pendingRecords.length; i++) {
        try {
          final success = await _saveToSupabase(table, pendingRecords[i]);
          if (success) {
            // Remove synced record
            pendingRecords.removeAt(i);
            i--; // Adjust index
          }
        } catch (e) {
          print('Error syncing pending data for $table: $e');
        }
      }

      if (pendingRecords.isEmpty) {
        _pendingSync.remove(table);
      } else {
        _pendingSync[table] = pendingRecords;
      }
    }

    // Save updated pending sync to local storage
    _savePendingSyncToStorage();
  }

  Future<void> _savePendingSyncToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSyncJson = json.encode(_pendingSync);
      await prefs.setString('pendingSyncData', pendingSyncJson);
    } catch (e) {
      print('Error saving pending sync to storage: $e');
    }
  }

  Future<void> _loadPendingSyncFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSyncJson = prefs.getString('pendingSyncData');
      if (pendingSyncJson != null) {
        final pendingSyncData =
            json.decode(pendingSyncJson) as Map<String, dynamic>;
        _pendingSync.clear();
        pendingSyncData.forEach((key, value) {
          final records =
              (value as List).map((e) => e as Map<String, dynamic>).toList();
          _pendingSync[key] = records;
        });
      }
    } catch (e) {
      print('Error loading pending sync from storage: $e');
    }
  }

  // Save data to Supabase or add to pending sync if offline
  Future<bool> saveDataToSupabase({
    required String apiEndpoint,
    required String tableName,
    required Map<String, dynamic> data,
    bool upsert = false,
    String? primaryKey,
  }) async {
    // Create a copy of the data to avoid modifying the original
    final dataToSave = Map<String, dynamic>.from(data);

    // Add timestamp if not present
    if (!dataToSave.containsKey('created_at')) {
      dataToSave['created_at'] = DateTime.now().toIso8601String();
    }

    if (!_isOnline.value) {
      // Save to pending sync
      if (!_pendingSync.containsKey(tableName)) {
        _pendingSync[tableName] = [];
      }
      _pendingSync[tableName]!.add(dataToSave);
      _savePendingSyncToStorage();
      return false;
    }

    try {
      return await _saveToSupabase(tableName, dataToSave);
    } catch (e) {
      print('Error saving data: $e');

      // Save to pending sync on error
      if (!_pendingSync.containsKey(tableName)) {
        _pendingSync[tableName] = [];
      }
      _pendingSync[tableName]!.add(dataToSave);
      _savePendingSyncToStorage();

      return false;
    }
  }

  Future<bool> _saveToSupabase(String table, Map<String, dynamic> data) async {
    try {
      if (_isUsingSupabase.value) {
        // Using Supabase SDK
        final response = await _supabase.from(table).upsert(data);
        return true;
      } else {
        // Using direct HTTP request
        final response = await _httpClient.post(
          Uri.parse('$_apiBaseUrl/$table'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer ${_supabase.auth.currentSession?.accessToken}'
          },
          body: json.encode(data),
        );
        return response.statusCode >= 200 && response.statusCode < 300;
      }
    } catch (e) {
      print('Error in _saveToSupabase: $e');
      return false;
    }
  }

  // Function to get data from Supabase
  Future<List<Map<String, dynamic>>> getData({
    required String tableName,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final sql =
          'SELECT * FROM "$tableName"${where != null ? ' WHERE $where' : ''}';
      final result = await _dbService.query(sql,
          substitutionValues: _createSubstitutionValues(whereArgs));
      return result;
    } catch (e) {
      print('Error getting data: $e');
      return [];
    }
  }

  Map<String, dynamic> _createSubstitutionValues(List<dynamic>? args) {
    if (args == null || args.isEmpty) return {};
    return Map.fromEntries(
        args.asMap().entries.map((e) => MapEntry('arg${e.key}', e.value)));
  }

  // Sync weight measurements with Supabase
  Future<bool> syncWeightMeasurement(Map<String, dynamic> data) async {
    return saveDataToSupabase(
      apiEndpoint: 'weight_measurements',
      tableName: 'weight_measurements',
      data: data,
    );
  }

  // Sync all pending data
  Future<bool> syncAllPending() async {
    if (!_isOnline.value) {
      return false;
    }

    try {
      await _syncPendingData();
      return _pendingSync.isEmpty;
    } catch (e) {
      print('Error syncing all pending data: $e');
      return false;
    }
  }

  // Sync data for specific tables
  Future<bool> syncSpecificTables(List<String> tables) async {
    if (!_isOnline.value) {
      return false;
    }

    bool allSuccess = true;
    for (final table in tables) {
      if (_pendingSync.containsKey(table)) {
        final pendingRecords = _pendingSync[table] ?? [];

        for (int i = 0; i < pendingRecords.length; i++) {
          try {
            final success = await _saveToSupabase(table, pendingRecords[i]);
            if (success) {
              pendingRecords.removeAt(i);
              i--; // Adjust index
            } else {
              allSuccess = false;
            }
          } catch (e) {
            print('Error syncing data for $table: $e');
            allSuccess = false;
          }
        }

        if (pendingRecords.isEmpty) {
          _pendingSync.remove(table);
        } else {
          _pendingSync[table] = pendingRecords;
        }
      }
    }

    _savePendingSyncToStorage();
    return allSuccess;
  }

  // Check for unsynchronized data
  Future<bool> hasUnsyncedData() async {
    if (!_isUsingSupabase.value) return false;

    try {
      // Doğrudan tablo adlarını biliyoruz, getTableNames gerekmiyor
      final tables = [
        'hayvanlar',
        'weight_measurements',
        'health_records',
        'tasks'
      ];

      for (final table in tables) {
        final result = await _dbService.query(
          'SELECT COUNT(*) as count FROM $table WHERE synced = 0',
        );

        final count =
            result.isNotEmpty ? (result.first['count'] as int? ?? 0) : 0;
        if (count > 0) return true;
      }

      return false;
    } catch (e) {
      print('Error checking for unsynced data: $e');
      return false;
    }
  }

  // Initialize connectivity check
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _processConnectivityResult(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      _isOnline.value = false;
    }
  }

  // Listen for connectivity changes
  void _startListening() {
    Connectivity().onConnectivityChanged.listen(_processConnectivityResult);
  }

  // Sync data with Supabase (used for specific tables)
  Future<bool> syncData({List<String>? specificTables}) async {
    if (!isUsingSupabase || isOffline) return false;

    try {
      bool allSuccess = true;
      final tablesToSync = specificTables ??
          [
            'hayvanlar',
            'hayvan_tartimlar',
            'sut_uretim',
            'asi_kayitlari',
            'tedavi_kayitlari',
            'dogum_kayitlari',
            'padok_hareketleri',
            'yapagi_kayitlari'
          ];

      for (String table in tablesToSync) {
        bool success = await _syncTableWithId(table, 'id');
        if (!success) {
          allSuccess = false;
          print('Sync failed for table: $table');
        }
      }

      return allSuccess;
    } catch (e) {
      print('Error during sync: $e');
      return false;
    }
  }

  Future<bool> _syncTableWithId(String tableName, String idColumn) async {
    try {
      print('Syncing table: $tableName');

      // Pull changes from Supabase
      final remoteData = await _supabaseAdapter.getTableData(tableName);
      if (remoteData == null) return false;

      // Update local database with remote data
      for (var record in remoteData) {
        final id = record[idColumn]?.toString();
        if (id != null) {
          final exists = await _checkRecordExists(tableName, id);
          if (exists) {
            await _updateRecord(tableName, id, record);
          } else {
            await _insertRecord(tableName, record);
          }
        }
      }

      // Push local changes to Supabase
      final localData = await _getTableData(tableName);
      if (localData != null) {
        for (var record in localData) {
          final id = record[idColumn]?.toString();
          if (id != null) {
            final exists =
                await _supabaseAdapter.checkRecordExists(tableName, id);
            if (exists) {
              await _supabaseAdapter.updateRecord(tableName, id, record);
            } else {
              await _supabaseAdapter.insertRecord(tableName, record);
            }
          }
        }
      }

      return true;
    } catch (e) {
      print('Error syncing table $tableName: $e');
      return false;
    }
  }

  Future<bool> _checkRecordExists(String tableName, String id) async {
    try {
      final sql =
          'SELECT EXISTS(SELECT 1 FROM "$tableName" WHERE id = @id) as exists';
      final result =
          await _dbService.query(sql, substitutionValues: {'id': id});
      return result.first['exists'] == 1;
    } catch (e) {
      print('Error checking record existence: $e');
      return false;
    }
  }

  Future<void> _updateRecord(
      String tableName, String id, Map<String, dynamic> record) async {
    try {
      await _dbService.updateRecord(
        tableName,
        record,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating record: $e');
      rethrow;
    }
  }

  Future<void> _insertRecord(
      String tableName, Map<String, dynamic> record) async {
    try {
      await _dbService.insertRecord(tableName, record);
    } catch (e) {
      print('Error inserting record: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _getTableData(String tableName) async {
    try {
      final sql = 'SELECT * FROM "$tableName"';
      return await _dbService.query(sql);
    } catch (e) {
      print('Error getting table data: $e');
      return [];
    }
  }
}
