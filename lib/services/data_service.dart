import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'api_service.dart';

class DataService {
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();

  bool _isOfflineMode = false;
  bool _isInitialized = false;

  // Constructor
  DataService() {
    _initServices();
  }

  // Initialize services
  Future<void> _initServices() async {
    if (!_isInitialized) {
      await _dbService.init();
      await _checkConnectionStatus();
      _isInitialized = true;
    }
  }

  // Check connection status to determine if we should use offline mode
  Future<void> _checkConnectionStatus() async {
    try {
      // First check database connection
      bool dbConnected = await _dbService.checkConnection();

      if (!dbConnected) {
        print('Database connection not available, switching to offline mode.');
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
  }

  // Get offline mode status
  bool get isOfflineMode => _isOfflineMode;

  // Switch to offline mode manually
  Future<void> switchToOfflineMode(bool value) async {
    _setOfflineMode(value);

    // Remember API availability status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('api_available', !value);
  }

  // Generic method to fetch data with automatic fallback to database
  Future<List<Map<String, dynamic>>> fetchData({
    required String apiEndpoint,
    required String tableName,
    Map<String, dynamic>? queryParams,
    String? whereClause,
    Map<String, dynamic>? substitutionValues,
  }) async {
    await _initServices();

    if (!_isOfflineMode) {
      try {
        // Try to fetch from API first
        final uri = Uri.parse('${_apiService.baseUrl}/$apiEndpoint')
            .replace(queryParameters: queryParams);

        final http.Response response = await http.get(uri, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token'
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data is List
              ? List<Map<String, dynamic>>.from(data.map(
                  (item) => item is Map ? Map<String, dynamic>.from(item) : {}))
              : [Map<String, dynamic>.from(data)];
        } else {
          // If API fails, fallback to database
          print('API request failed, falling back to database');
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API request error: $e');
        _setOfflineMode(true);
      }
    }

    // If we're in offline mode or API request failed, get from database
    String query = 'SELECT * FROM $tableName';
    if (whereClause != null && whereClause.isNotEmpty) {
      query += ' WHERE $whereClause';
    }

    return await _dbService.query(query,
        substitutionValues: substitutionValues);
  }

  // Generic method to save data with automatic fallback to database
  Future<bool> saveData({
    required String apiEndpoint,
    required String tableName,
    required Map<String, dynamic> data,
    bool isUpdate = false,
    String? primaryKeyField,
  }) async {
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Try to save to API first
        final uri = Uri.parse('${_apiService.baseUrl}/$apiEndpoint');
        final http.Response response;

        if (isUpdate) {
          response = await http.put(uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer token'
              },
              body: json.encode(data));
        } else {
          response = await http.post(uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer token'
              },
              body: json.encode(data));
        }

        success = response.statusCode >= 200 && response.statusCode < 300;

        if (!success) {
          // If API fails, fallback to database
          print('API save failed, falling back to database');
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API save error: $e');
        _setOfflineMode(true);
      }
    }

    // If we're in offline mode or API request failed, save to database
    if (_isOfflineMode || !success) {
      // Generate SQL for insert or update
      if (isUpdate && primaryKeyField != null) {
        // For update
        final setClause = data.entries
            .where((e) => e.key != primaryKeyField)
            .map((e) => '"${e.key}" = @${e.key}')
            .join(', ');

        final sql =
            'UPDATE "$tableName" SET $setClause WHERE "$primaryKeyField" = @$primaryKeyField';
        return await _dbService.execute(sql, substitutionValues: data);
      } else {
        // For insert
        final columns = data.keys.map((k) => '"$k"').join(', ');
        final values = data.keys.map((k) => '@$k').join(', ');
        final sql = 'INSERT INTO "$tableName" ($columns) VALUES ($values)';
        return await _dbService.execute(sql, substitutionValues: data);
      }
    }

    return success;
  }

  // Generic method to delete data
  Future<bool> deleteData({
    required String apiEndpoint,
    required String tableName,
    required String primaryKeyField,
    required dynamic primaryKeyValue,
  }) async {
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // Try to delete from API first
        final uri =
            Uri.parse('${_apiService.baseUrl}/$apiEndpoint/$primaryKeyValue');

        final http.Response response = await http.delete(uri, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token'
        });

        success = response.statusCode >= 200 && response.statusCode < 300;

        if (!success) {
          // If API fails, fallback to database
          print('API delete failed, falling back to database');
          _setOfflineMode(true);
        }
      } catch (e) {
        print('API delete error: $e');
        _setOfflineMode(true);
      }
    }

    // If we're in offline mode or API request failed, delete from database
    if (_isOfflineMode || !success) {
      final sql = 'DELETE FROM "$tableName" WHERE "$primaryKeyField" = @value';
      return await _dbService
          .execute(sql, substitutionValues: {'value': primaryKeyValue});
    }

    return success;
  }

  // HAYVAN NOT İŞLEMLERİ
  Future<List<Map<String, dynamic>>> getHayvanNotlari(int hayvanId) async {
    await _initServices();

    if (!_isOfflineMode) {
      try {
        final apiResponse = await _apiService.getHayvanNotlari(hayvanId);
        if (apiResponse.containsKey('hayvan_notlari') &&
            apiResponse['hayvan_notlari'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(apiResponse['hayvan_notlari']);
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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        final apiResponse = await _apiService.createHayvanNot(data);
        success = apiResponse.isNotEmpty;

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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success = await _apiService.updateHayvanNot(notId, data);

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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success = await _apiService.deleteHayvanNot(notId);

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
    await _initServices();

    if (!_isOfflineMode) {
      try {
        final apiResponse = await _apiService.getKullaniciAyarlari(kullaniciId);
        if (apiResponse.containsKey('kullanici_ayarlari') &&
            apiResponse['kullanici_ayarlari'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(
              apiResponse['kullanici_ayarlari']);
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
    await _initServices();

    final ayarlar = await getKullaniciAyarlari(kullaniciId);

    for (var ayar in ayarlar) {
      if (ayar['ayar_tipi'] == ayarTipi) {
        return ayar;
      }
    }

    return {};
  }

  Future<bool> setKullaniciAyar(Map<String, dynamic> data) async {
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success = await _apiService.updateKullaniciAyar(data);

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
    await _initServices();

    if (!_isOfflineMode) {
      try {
        final apiResponse = await _apiService.getBildirimler(
          kullaniciId,
          sadeceMevcutHafta: sadeceMevcutHafta,
          sadeceOkunmamis: sadeceOkunmamis,
        );

        if (apiResponse.containsKey('bildirimler') &&
            apiResponse['bildirimler'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(apiResponse['bildirimler']);
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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success = await _apiService.createBildirim(data);

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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        await _apiService.bildirimOkundu(bildirimId);
        success = true;
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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        // API'de bu işlev olmayabilir, bu durumda veritabanında yapılır
        _setOfflineMode(true);
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
    await _initServices();

    if (!_isOfflineMode) {
      try {
        final apiResponse = await _apiService.getGunlukAktiviteler(
          baslangicTarihi: baslangicTarihi,
          bitisTarihi: bitisTarihi,
          aktiviteTipi: aktiviteTipi,
          kullaniciId: kullaniciId,
        );

        if (apiResponse.containsKey('gunluk_aktiviteler') &&
            apiResponse['gunluk_aktiviteler'].isNotEmpty) {
          var aktiviteler = List<Map<String, dynamic>>.from(
              apiResponse['gunluk_aktiviteler']);

          // Durum filtresi API'de yoksa burada uygula
          if (durum != null) {
            aktiviteler =
                aktiviteler.where((a) => a['durum'] == durum).toList();
          }

          return aktiviteler;
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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success = await _apiService.createGunlukAktivite(data);

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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success =
            await _apiService.updateGunlukAktiviteDurum(aktiviteId, yeniDurum);

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
    await _initServices();

    bool success = false;

    if (!_isOfflineMode) {
      try {
        success = await _apiService.updateGunlukAktiviteDurum(
            aktiviteId, 'tamamlandı');

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
}
