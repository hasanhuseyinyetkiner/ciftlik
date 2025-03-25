import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final String _tokenKey = 'auth_token';
  String? _authToken;
  bool _isInitialized = false;
  bool _isOfflineMode = false;

  // HTTP Client with persistent connections
  final http.Client _httpClient = http.Client();

  // Improved timeout values
  final Duration _connectionTimeout =
      Duration(seconds: ApiConfig.connectionTimeout);
  final Duration _receiveTimeout = Duration(seconds: ApiConfig.receiveTimeout);

  // Cache for API responses
  final Map<String, _ApiCacheEntry> _responseCache = {};
  final Duration _defaultCacheDuration = Duration(minutes: 15);

  ApiService() {
    _loadToken();
  }

  // Getter for offline mode
  bool get isOfflineMode => _isOfflineMode;

  // Set offline mode
  void setOfflineMode(bool value) {
    _isOfflineMode = value;
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

  // Check if network is available
  Future<bool> _isNetworkAvailable() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Network check error: $e');
      return false;
    }
  }

  // Helper method to handle API calls safely with improved caching
  Future<http.Response> _safeApiCall(
      Future<http.Response> apiCall, String cacheKey,
      {bool useCache = true,
      Duration? cacheDuration,
      bool forceRefresh = false}) async {
    // Check if we're offline
    if (_isOfflineMode) {
      // Return cached response if available
      if (_responseCache.containsKey(cacheKey)) {
        final cachedResponse = _responseCache[cacheKey]!;
        print('Returning cached response in offline mode');
        return cachedResponse.response;
      }
      throw ApiException(
        statusCode: 0,
        message: 'Offline mode active and no cached data available',
      );
    }

    // Check network connectivity first
    bool isConnected = await _isNetworkAvailable();
    if (!isConnected) {
      // Return cached response if available when offline
      if (_responseCache.containsKey(cacheKey)) {
        final cachedResponse = _responseCache[cacheKey]!;
        print('No network connection, returning cached response');
        return cachedResponse.response;
      }
      throw ApiException(
        statusCode: 0,
        message: 'No network connection available',
      );
    }

    // Return cached response if not expired and not forcing refresh
    if (useCache && !forceRefresh && _responseCache.containsKey(cacheKey)) {
      final cachedResponse = _responseCache[cacheKey]!;
      if (!cachedResponse.isExpired()) {
        print('Returning cached API response');
        return cachedResponse.response;
      }
    }

    try {
      final response = await apiCall.timeout(_connectionTimeout);

      // API hata kontrolü
      if (response.statusCode >= 400) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response) ?? 'API hatası',
        );
      }

      // Cache successful responses
      if (useCache && response.statusCode >= 200 && response.statusCode < 300) {
        _responseCache[cacheKey] = _ApiCacheEntry(
          response,
          cacheDuration ?? _defaultCacheDuration,
        );
      }

      return response;
    } on http.ClientException catch (e) {
      print('Client exception: ${e.message}');
      // Return cached response if available on error
      if (_responseCache.containsKey(cacheKey)) {
        print('Network error, returning cached response');
        return _responseCache[cacheKey]!.response;
      }
      throw ApiException(
        statusCode: 0,
        message: 'Bağlantı hatası: ${e.message}',
      );
    } on TimeoutException catch (_) {
      print('Connection timeout');
      // Return cached response if available on timeout
      if (_responseCache.containsKey(cacheKey)) {
        print('Connection timeout, returning cached response');
        return _responseCache[cacheKey]!.response;
      }
      throw ApiException(
        statusCode: 408,
        message: 'Bağlantı zaman aşımına uğradı',
      );
    } catch (e) {
      print('Unexpected error: $e');
      // Return cached response if available on other errors
      if (_responseCache.containsKey(cacheKey)) {
        print('Error occurred, returning cached response');
        return _responseCache[cacheKey]!.response;
      }
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
  Map<String, String>? get _authHeaders {
    if (_authToken != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
        'Connection':
            'keep-alive', // Keep connection alive for better performance
      };
    } else {
      // Use basic auth if no token is available
      final basicAuthHeaders = ApiConfig.getBasicAuthHeaders();
      basicAuthHeaders['Connection'] = 'keep-alive';
      return basicAuthHeaders;
    }
  }

  // Clear cache entry by key
  void clearCacheEntry(String key) {
    _responseCache.remove(key);
  }

  // Clear all cache
  void clearAllCache() {
    _responseCache.clear();
    print('All API cache cleared');
  }

  // Calculate cache key from endpoint and params
  String _createCacheKey(String endpoint, [Map<String, dynamic>? params]) {
    if (params == null || params.isEmpty) {
      return endpoint;
    }
    return '$endpoint:${jsonEncode(params)}';
  }

  // AUTH APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/Users/login'),
      headers: {'Content-Type': 'application/json', 'Connection': 'keep-alive'},
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
    clearAllCache(); // Clear all cache on logout
  }

  // HAYVAN YÖNETİMİ APIs with caching
  Future<Map<String, dynamic>> getHayvanlar({bool forceRefresh = false}) async {
    await _initialize();
    final cacheKey = _createCacheKey('/AnimalType');

    try {
      final response = await _safeApiCall(
        _httpClient.get(Uri.parse('$baseUrl/AnimalType'),
            headers: _authHeaders),
        cacheKey,
        forceRefresh: forceRefresh,
        cacheDuration: Duration(
            minutes: 30), // Longer cache for infrequently changing data
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'hayvanlar': rawData
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
    final cacheKey = _createCacheKey('/AnimalType/$id');

    final response = await _safeApiCall(
      _httpClient.get(Uri.parse('$baseUrl/AnimalType/$id'),
          headers: _authHeaders),
      cacheKey,
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

      final cacheKey = _createCacheKey('/AnimalType/create', apiData);

      final response = await _safeApiCall(
        _httpClient.post(
          Uri.parse('$baseUrl/AnimalType'),
          headers: _authHeaders,
          body: jsonEncode(apiData),
        ),
        cacheKey,
        useCache: false, // Don't cache POST requests
      );

      // Clear hayvanlar cache since we've added a new one
      clearCacheEntry(_createCacheKey('/AnimalType'));

      return jsonDecode(response.body);
    } catch (e) {
      print('Hayvan eklenirken hata: $e');
      return {};
    }
  }

  // SAĞLIK KAYITLARI APIs
  Future<Map<String, dynamic>> getSaglikKayitlari() async {
    await _initialize();
    final cacheKey = _createCacheKey('/HealthRecords');

    try {
      final response = await _safeApiCall(
        _httpClient.get(Uri.parse('$baseUrl/HealthRecords'),
            headers: _authHeaders),
        cacheKey,
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'saglik_kayitlari': rawData
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

  // SÜT ÖLÇÜMÜ APIs
  Future<Map<String, dynamic>> getSutOlcumleri() async {
    await _initialize();
    final cacheKey = _createCacheKey('/MilkMeasurements');

    try {
      final response = await _safeApiCall(
        _httpClient.get(Uri.parse('$baseUrl/MilkMeasurements'),
            headers: _authHeaders),
        cacheKey,
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'sut_olcumleri': rawData
            .map(
              (record) => {
                'id': record['id'],
                'hayvan_id': record['animalId'],
                'tarih': record['date'],
                'miktar': record['amount'],
                'kalite': record['quality'] ?? '',
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

  // GELİR GİDER APIs
  Future<Map<String, dynamic>> getGelirGider() async {
    await _initialize();
    final cacheKey = _createCacheKey('/FinancialRecords');

    try {
      final response = await _safeApiCall(
        _httpClient.get(Uri.parse('$baseUrl/FinancialRecords'),
            headers: _authHeaders),
        cacheKey,
      );

      final List<dynamic> rawData = jsonDecode(response.body);

      // Format API response for database sync
      final Map<String, dynamic> formattedData = {
        'gelir_gider': rawData
            .map(
              (record) => {
                'id': record['id'],
                'tarih': record['date'],
                'miktar': record['amount'],
                'tur': record['type'], // gelir veya gider
                'kategori': record['category'],
                'aciklama': record['description'],
              },
            )
            .toList(),
      };

      return formattedData;
    } catch (e) {
      print('Gelir gider kayıtları alınırken hata: $e');
      return {'gelir_gider': []};
    }
  }

  // Make sure to close the HTTP client when done
  void dispose() {
    _httpClient.close();
  }
}

// API Exception class definition
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

// API Cache entry class
class _ApiCacheEntry {
  final http.Response response;
  final DateTime expiryTime;

  _ApiCacheEntry(this.response, Duration duration)
      : expiryTime = DateTime.now().add(duration);

  bool isExpired() {
    return DateTime.now().isAfter(expiryTime);
  }
}
