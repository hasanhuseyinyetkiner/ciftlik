import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = 'http://146.190.54.51/api';
  final String _tokenKey = 'auth_token';
  String? _authToken;
  bool _isInitialized = false;

  // Timeout değerleri
  final Duration _connectionTimeout = const Duration(seconds: 30);
  final Duration _receiveTimeout = const Duration(seconds: 30);

  ApiService() {
    _loadToken();
  }

  // Initialize method to ensure token is loaded
  Future<void> _initialize() async {
    if (!_isInitialized) {
      await _loadToken();
      _isInitialized = true;
    }
  }

  // Load token from shared preferences
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_tokenKey);
    } catch (e) {
      print('Token yüklenirken hata: $e');
    }
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _authToken = token;
    } catch (e) {
      print('Token kaydedilirken hata: $e');
    }
  }

  // Clear token from shared preferences
  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _authToken = null;
    } catch (e) {
      print('Token silinirken hata: $e');
    }
  }

  // Helper method to handle API calls safely
  Future<http.Response> _safeApiCall(Future<http.Response> apiCall) async {
    try {
      final response = await apiCall.timeout(_connectionTimeout);

      // API hata kontrolü
      if (response.statusCode >= 400) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response) ?? 'API hatası',
        );
      }

      return response;
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Bağlantı hatası: ${e.message}',
      );
    } on TimeoutException catch (_) {
      throw ApiException(
        statusCode: 408,
        message: 'Bağlantı zaman aşımına uğradı',
      );
    } catch (e) {
      throw ApiException(statusCode: 0, message: 'Beklenmeyen hata: $e');
    }
  }

  // Parse error message from response
  String? _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? data['error'];
    } catch (_) {
      return response.body;
    }
  }

  // HTTP Headers with authentication
  Map<String, String> get _headers {
    if (_authToken != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      };
    } else {
      return {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode("MerlabUser:kWz*7jq8[;71"))}',
      };
    }
  }

  // AUTH APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // HAYVAN YÖNETİMİ APIs
  Future<Map<String, dynamic>> getHayvanlar() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/AnimalType'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'hayvanlar':
            rawData
                .map(
                  (animal) => {
                    'id': animal['id'],
                    'kimlik_no': animal['identificationNumber'] ?? '',
                    'tur': animal['animalType'] ?? '',
                    'alt_tur': animal['animalSubType'] ?? '',
                    'cinsiyet': animal['gender'] ?? '',
                    'dogum_tarihi': animal['birthDate'],
                    'anne_id': animal['motherId'],
                    'baba_id': animal['fatherId'],
                    'durum': animal['status'] ?? 'aktif',
                    'geldiği_yer': animal['source'],
                    'gelis_tarihi': animal['acquisitionDate'],
                    'aciklama': animal['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Hayvanlar alınırken hata: $e');
      return {'hayvanlar': []};
    }
  }

  Future<Map<String, dynamic>> getHayvan(int id) async {
    await _initialize();
    final response = await _safeApiCall(
      http.get(Uri.parse('$baseUrl/AnimalType/$id'), headers: _headers),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createHayvan(Map<String, dynamic> data) async {
    await _initialize();
    try {
      // Convert data to API format
      final apiData = {
        'identificationNumber': data['kimlik_no'],
        'animalType': data['tur'],
        'animalSubType': data['alt_tur'],
        'gender': data['cinsiyet'],
        'birthDate': data['dogum_tarihi'],
        'motherId': data['anne_id'],
        'fatherId': data['baba_id'],
        'status': data['durum'],
        'source': data['geldiği_yer'],
        'acquisitionDate': data['gelis_tarihi'],
        'notes': data['aciklama'],
      };

      final response = await _safeApiCall(
        http.post(
          Uri.parse('$baseUrl/AnimalType'),
          headers: _headers,
          body: jsonEncode(apiData),
        ),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Hayvan eklenirken hata: $e');
      return {};
    }
  }

  // SAĞLIK KAYITLARI APIs
  Future<Map<String, dynamic>> getSaglikKayitlari() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/HealthRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'saglik_kayitlari':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'muayene_tarihi': record['examinationDate'],
                    'bulgular': record['findings'],
                    'tani': record['diagnosis'],
                    'tedavi': record['treatment'],
                    'ilac': record['medication'],
                    'doz': record['dosage'],
                    'veteriner': record['veterinarian'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Sağlık kayıtları alınırken hata: $e');
      return {'saglik_kayitlari': []};
    }
  }

  // AŞI KAYITLARI APIs
  Future<Map<String, dynamic>> getAsiKayitlari() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/VaccinationRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'asi_kayitlari':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'asi_adi': record['vaccineName'],
                    'uygulama_tarihi': record['administrationDate'],
                    'sonraki_asi_tarihi': record['nextVaccinationDate'],
                    'uygulayan': record['administrator'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Aşı kayıtları alınırken hata: $e');
      return {'asi_kayitlari': []};
    }
  }

  // SÜT ÖLÇÜM APIs
  Future<Map<String, dynamic>> getSutOlcumleri() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/MilkRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'sut_olcumleri':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'olcum_tarihi': record['measurementDate'],
                    'sabah_olcumu': record['morningMeasurement'],
                    'aksam_olcumu': record['eveningMeasurement'],
                    'toplam_miktar': record['totalAmount'],
                    'kalite': record['quality'],
                    'sicaklik': record['temperature'],
                    'ph': record['ph'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Süt ölçümleri alınırken hata: $e');
      return {'sut_olcumleri': []};
    }
  }

  Future<Map<String, dynamic>> createSutOlcumu(
    Map<String, dynamic> data,
  ) async {
    await _initialize();
    try {
      // Convert data to API format
      final apiData = {
        'animalId': data['hayvan_id'],
        'measurementDate': data['olcum_tarihi'],
        'morningMeasurement': data['sabah_olcumu'],
        'eveningMeasurement': data['aksam_olcumu'],
        'totalAmount': data['toplam_miktar'],
        'quality': data['kalite'],
        'temperature': data['sicaklik'],
        'ph': data['ph'],
        'notes': data['notlar'],
      };

      final response = await _safeApiCall(
        http.post(
          Uri.parse('$baseUrl/MilkRecords'),
          headers: _headers,
          body: jsonEncode(apiData),
        ),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Süt ölçümü eklenirken hata: $e');
      return {};
    }
  }

  // GELİR-GİDER APIs
  Future<Map<String, dynamic>> getGelirGider() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/FinancialRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'gelir_gider':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'tur': record['type'],
                    'kategori': record['category'],
                    'miktar': record['amount'],
                    'tarih': record['date'],
                    'aciklama': record['description'],
                    'belge_no': record['documentNumber'],
                    'odeme_sekli': record['paymentMethod'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Finansal kayıtlar alınırken hata: $e');
      return {'gelir_gider': []};
    }
  }

  Future<Map<String, dynamic>> createGelirGider(
    Map<String, dynamic> data,
  ) async {
    await _initialize();
    try {
      // Convert data to API format
      final apiData = {
        'type': data['tur'],
        'category': data['kategori'],
        'amount': data['miktar'],
        'date': data['tarih'],
        'description': data['aciklama'],
        'documentNumber': data['belge_no'],
        'paymentMethod': data['odeme_sekli'],
      };

      final response = await _safeApiCall(
        http.post(
          Uri.parse('$baseUrl/FinancialRecords'),
          headers: _headers,
          body: jsonEncode(apiData),
        ),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Finansal kayıt eklenirken hata: $e');
      return {};
    }
  }

  // TARTIM KAYITLARI APIs
  Future<Map<String, dynamic>> getTartimKayitlari() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/WeightRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'tartim_kayitlari':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'tartim_tarihi': record['weightDate'],
                    'agirlik': record['weight'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Tartım kayıtları alınırken hata: $e');
      return {'tartim_kayitlari': []};
    }
  }

  // GEBELİK KONTROL APIs
  Future<Map<String, dynamic>> getGebelikKontrolleri() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/PregnancyChecks'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'gebelik_kontrolleri':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'kontrol_tarihi': record['checkDate'],
                    'durum': record['status'],
                    'tahmini_dogum_tarihi': record['estimatedBirthDate'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Gebelik kontrolleri alınırken hata: $e');
      return {'gebelik_kontrolleri': []};
    }
  }

  // YEM KAYITLARI APIs
  Future<Map<String, dynamic>> getYemKayitlari() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/FeedRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'yem_kayitlari':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'grup_id': record['groupId'],
                    'yem_cinsi': record['feedType'],
                    'miktar': record['amount'],
                    'birim': record['unit'],
                    'tarih': record['date'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Yem kayıtları alınırken hata: $e');
      return {'yem_kayitlari': []};
    }
  }

  // SU TÜKETİM KAYITLARI APIs
  Future<Map<String, dynamic>> getSuTuketimKayitlari() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/WaterRecords'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'su_tuketim_kayitlari':
            rawData
                .map(
                  (record) => {
                    'id': record['id'],
                    'hayvan_id': record['animalId'],
                    'grup_id': record['groupId'],
                    'miktar': record['amount'],
                    'tarih': record['date'],
                    'notlar': record['notes'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Su tüketim kayıtları alınırken hata: $e');
      return {'su_tuketim_kayitlari': []};
    }
  }

  // BİLDİRİM YÖNETİMİ APIs
  Future<Map<String, dynamic>> getBildirimler() async {
    await _initialize();
    try {
      final response = await _safeApiCall(
        http.get(Uri.parse('$baseUrl/Notifications'), headers: _headers),
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'bildirimler':
            rawData
                .map(
                  (notification) => {
                    'id': notification['id'],
                    'baslik': notification['title'],
                    'mesaj': notification['message'],
                    'tip': notification['type'],
                    'okundu': notification['isRead'] ? 1 : 0,
                    'ilgili_id': notification['relatedId'],
                    'ilgili_tablo': notification['relatedTable'],
                    'olusturma_tarihi': notification['creationDate'],
                  },
                )
                .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Bildirimler alınırken hata: $e');
      return {'bildirimler': []};
    }
  }

  Future<void> bildirimOkundu(int id) async {
    await _initialize();
    try {
      await _safeApiCall(
        http.put(
          Uri.parse('$baseUrl/Notifications/$id/read'),
          headers: _headers,
        ),
      );
    } catch (e) {
      print('Bildirim okundu işaretlenirken hata: $e');
    }
  }

  // HATA SINIFI
  Future<void> raporHataGonder(String hataMetni, String ekBilgi) async {
    await _initialize();
    await _safeApiCall(
      http.post(
        Uri.parse('$baseUrl/ErrorReports'),
        headers: _headers,
        body: jsonEncode({
          'errorText': hataMetni,
          'additionalInfo': ekBilgi,
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ),
    );
  }
}

// API Hata Sınıfı
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}
