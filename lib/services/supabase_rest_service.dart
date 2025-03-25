import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SupabaseRestService {
  // Singleton pattern
  static final SupabaseRestService _instance = SupabaseRestService._internal();
  factory SupabaseRestService() => _instance;
  SupabaseRestService._internal();

  String _supabaseUrl = '';
  String _supabaseKey = '';
  bool _isInitialized = false;
  bool _isOfflineMode = false;
  final Map<String, dynamic> _cache = {};

  // Initialization
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Dotenv'den değerleri almayı dene
      _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      _supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      // Değerler boşsa hard-coded değerleri kullan
      if (_supabaseUrl.isEmpty || _supabaseKey.isEmpty) {
        _supabaseUrl = 'https://wahoyhkhwvetpopnopqa.supabase.co';
        _supabaseKey =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhaG95aGtod3ZldHBvcG5vcHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0NjcwMTksImV4cCI6MjA1ODA0MzAxOX0.fG9eMAdGsFONMVKSIOt8QfkZPRBjrSsoKrxgCbgAbhY';
      }

      print('SupabaseRestService initialized with URL: $_supabaseUrl');

      // Check connection
      bool connected = await checkConnection();

      if (connected) {
        // Önce tabloları ve fonksiyonları listeleyelim
        await listTablesWithRestApi();

        // Gerekli fonksiyonları veya tabloları kontrolü
        await directTableAccess();
      }

      _isInitialized = true;
    } catch (e) {
      print('SupabaseRestService init error: $e');
      _isOfflineMode = true;
    }
  }

  // List all tables using REST API
  Future<void> listTablesWithRestApi() async {
    try {
      print('Fetching tables and functions with REST API...');

      // Get all tables from information schema
      final response = await http.get(
        Uri.parse(
            '$_supabaseUrl/rest/v1/information_schema/tables?select=table_schema,table_name&table_schema=eq.public'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final tables = json.decode(response.body);
        print('Tables found: ${tables.length}');
        for (var table in tables) {
          print(' - ${table['table_schema']}.${table['table_name']}');
        }
      } else {
        print('Failed to fetch tables: ${response.body}');
      }

      // Check if hayvanlar table exists
      final hayvanlarResponse = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/hayvanlar?select=count&limit=1'),
        headers: _headers,
      );

      if (hayvanlarResponse.statusCode >= 200 &&
          hayvanlarResponse.statusCode < 300) {
        print('Hayvanlar table exists!');
      } else {
        print(
            'Hayvanlar table does not exist or not accessible: ${hayvanlarResponse.statusCode}');
        print('Response: ${hayvanlarResponse.body}');
      }
    } catch (e) {
      print('Error listing tables with REST API: $e');
    }
  }

  // Try direct table access to create tables if needed
  Future<void> directTableAccess() async {
    try {
      // Try to access hayvanlar table
      bool hayvanlarExists = await _checkTableExists('hayvanlar');

      // Create hayvanlar table if it doesn't exist
      if (!hayvanlarExists) {
        await _createHayvanlarTable();
      }
    } catch (e) {
      print('Error in directTableAccess: $e');
    }
  }

  // Check if a table exists
  Future<bool> _checkTableExists(String tableName) async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/$tableName?select=count&limit=1'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Table $tableName exists');
        return true;
      } else {
        print(
            'Table $tableName does not exist or not accessible: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error checking if table $tableName exists: $e');
      return false;
    }
  }

  // Create hayvanlar table directly
  Future<bool> _createHayvanlarTable() async {
    try {
      print('Creating hayvanlar table via REST API...');

      // Create hayvanlar table
      const createTableSQL = '''
      CREATE TABLE IF NOT EXISTS public.hayvanlar (
        id SERIAL PRIMARY KEY,
        kupe_no VARCHAR(50) UNIQUE NOT NULL,
        tur VARCHAR(50) NOT NULL,
        irk VARCHAR(100),
        cinsiyet VARCHAR(20) NOT NULL,
        dogum_tarihi DATE,
        anne_kupe_no VARCHAR(50),
        baba_kupe_no VARCHAR(50),
        ağırlık DECIMAL(10, 2),
        durum VARCHAR(50) DEFAULT 'aktif',
        notlar TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      ''';

      // We need to use SQL editor in Supabase Dashboard to create this table
      // since we don't have exec_sql function

      print('Please run the following SQL in Supabase SQL Editor:');
      print(createTableSQL);

      return false;
    } catch (e) {
      print('Error creating hayvanlar table: $e');
      return false;
    }
  }

  // Basic headers for all requests
  Map<String, String> get _headers => {
        'apikey': _supabaseKey,
        'Authorization': 'Bearer $_supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      };

  // Check connection with HTTP
  Future<bool> checkConnection() async {
    try {
      // First check network connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _isOfflineMode = true;
        return false;
      }

      // Try to access the Supabase REST API directly
      final response = await http
          .get(
            Uri.parse('$_supabaseUrl/rest/v1/'),
            headers: _headers,
          )
          .timeout(Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Supabase REST connection successful');
        _isOfflineMode = false;
        return true;
      } else {
        print(
            'Supabase REST connection failed with status: ${response.statusCode}');
        _isOfflineMode = true;
        return false;
      }
    } catch (e) {
      print('Error checking Supabase REST connection: $e');
      _isOfflineMode = true;
      return false;
    }
  }

  // Create the necessary RPC functions
  Future<bool> createRpcFunctions() async {
    try {
      // SQL for creating RPC functions
      const String rpcFunctionsSQL = '''
      -- Ping function for connection testing
      CREATE OR REPLACE FUNCTION public.ping()
      RETURNS TEXT
      LANGUAGE sql
      SECURITY DEFINER
      AS \$\$
          SELECT 'pong'::TEXT;
      \$\$;

      -- Grant permissions
      GRANT EXECUTE ON FUNCTION public.ping() TO authenticated;
      GRANT EXECUTE ON FUNCTION public.ping() TO anon;
      GRANT EXECUTE ON FUNCTION public.ping() TO service_role;

      -- Execute SQL function
      CREATE OR REPLACE FUNCTION public.exec_sql(query text)
      RETURNS JSONB
      LANGUAGE plpgsql
      SECURITY DEFINER
      AS \$\$
      DECLARE
          result JSONB;
      BEGIN
          EXECUTE query;
          RETURN jsonb_build_object('success', true);
      EXCEPTION WHEN OTHERS THEN
          RETURN jsonb_build_object('success', false, 'error', SQLERRM);
      END;
      \$\$;

      -- Grant permissions
      GRANT EXECUTE ON FUNCTION public.exec_sql(text) TO authenticated;
      GRANT EXECUTE ON FUNCTION public.exec_sql(text) TO anon;
      GRANT EXECUTE ON FUNCTION public.exec_sql(text) TO service_role;

      -- List tables function
      CREATE OR REPLACE FUNCTION public.list_tables()
      RETURNS SETOF JSONB
      LANGUAGE plpgsql
      SECURITY DEFINER
      AS \$\$
      BEGIN
          RETURN QUERY
              SELECT jsonb_build_object(
                  'table_name', table_name,
                  'table_schema', table_schema
              )
              FROM information_schema.tables 
              WHERE table_schema = 'public'
              ORDER BY table_name;
      END;
      \$\$;

      -- Grant permissions
      GRANT EXECUTE ON FUNCTION public.list_tables() TO authenticated;
      GRANT EXECUTE ON FUNCTION public.list_tables() TO anon;
      GRANT EXECUTE ON FUNCTION public.list_tables() TO service_role;
      ''';

      // Direct SQL execution using Supabase REST API
      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/rpc/exec_sql'),
        headers: _headers,
        body: json.encode({
          'query': rpcFunctionsSQL,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Successfully created RPC functions');
        return true;
      } else {
        print('Failed to create RPC functions: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating RPC functions: $e');
      return false;
    }
  }

  // Call an RPC function
  Future<dynamic> callRpc(String functionName,
      {Map<String, dynamic>? params}) async {
    await _ensureInitialized();

    if (_isOfflineMode) return null;

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/rpc/$functionName'),
        headers: _headers,
        body: params != null ? json.encode(params) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else {
        print('RPC call to $functionName failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling RPC $functionName: $e');
      return null;
    }
  }

  // Execute a raw SQL query
  Future<List<Map<String, dynamic>>?> executeRawQuery(
    String query, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    await _ensureInitialized();

    if (_isOfflineMode) return null;

    try {
      final result = await callRpc('exec_sql', params: {
        'query': query,
      });

      if (result != null && result['success'] == true) {
        print('Raw SQL query executed successfully');
        // For queries that return data, we would need to modify exec_sql function
        // to return the actual data. For now, we return an empty list.
        return [];
      } else {
        print(
            'Error executing raw SQL query: ${result?['error'] ?? "Unknown error"}');
        return null;
      }
    } catch (e) {
      print('Exception executing raw SQL query: $e');
      return null;
    }
  }

  // Ensure all required tables exist
  Future<bool> ensureTablesExist() async {
    try {
      print('Checking if required tables exist...');

      // Get list of existing tables
      final tablesResult = await callRpc('list_tables');
      if (tablesResult == null) {
        print('Could not get tables list');
        return false;
      }

      // Extract table names
      final existingTables = <String>{};
      for (var table in tablesResult) {
        if (table.containsKey('table_name')) {
          existingTables.add(table['table_name'].toString());
        }
      }

      print('Existing tables: $existingTables');

      // Define required tables
      final requiredTables = [
        'hayvanlar',
        'hayvan_not',
        'kullanici_ayar',
        'bildirim',
        'gunluk_aktivite'
      ];

      // Check which tables are missing
      final missingTables = requiredTables
          .where((table) => !existingTables.contains(table))
          .toList();

      if (missingTables.isEmpty) {
        print('All required tables exist');
        return true;
      }

      print('Tables to create: $missingTables');

      // Create missing tables
      for (var table in missingTables) {
        bool created = await _createTable(table);
        if (!created) {
          print('Failed to create table: $table');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error ensuring tables exist: $e');
      return false;
    }
  }

  // Create a specific table based on its name
  Future<bool> _createTable(String tableName) async {
    try {
      String createTableSQL = '';

      switch (tableName) {
        case 'hayvanlar':
          createTableSQL = '''
          CREATE TABLE public.hayvanlar (
            id SERIAL PRIMARY KEY,
            kupe_no VARCHAR(50) UNIQUE NOT NULL,
            tur VARCHAR(50) NOT NULL,
            irk VARCHAR(100),
            cinsiyet VARCHAR(20) NOT NULL,
            dogum_tarihi DATE,
            anne_kupe_no VARCHAR(50),
            baba_kupe_no VARCHAR(50),
            ağırlık DECIMAL(10, 2),
            durum VARCHAR(50) DEFAULT 'aktif',
            notlar TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
          ''';
          break;

        case 'hayvan_not':
          createTableSQL = '''
          CREATE TABLE public.hayvan_not (
            id SERIAL PRIMARY KEY,
            hayvan_id INTEGER NOT NULL REFERENCES hayvanlar(id) ON DELETE CASCADE,
            not_tipi VARCHAR(50) NOT NULL,
            icerik TEXT NOT NULL,
            tarih TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            kullanici_id INTEGER,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
          ''';
          break;

        case 'kullanici_ayar':
          createTableSQL = '''
          CREATE TABLE public.kullanici_ayar (
            ayar_id SERIAL PRIMARY KEY,
            kullanici_id INTEGER NOT NULL,
            ayar_tipi VARCHAR(50) NOT NULL,
            ayar_degeri TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(kullanici_id, ayar_tipi)
          );
          ''';
          break;

        case 'bildirim':
          createTableSQL = '''
          CREATE TABLE public.bildirim (
            id SERIAL PRIMARY KEY,
            kullanici_id INTEGER NOT NULL,
            baslik VARCHAR(100) NOT NULL,
            mesaj TEXT NOT NULL,
            bildirim_tipi VARCHAR(50) NOT NULL,
            okundu_mu BOOLEAN DEFAULT FALSE,
            goruldu_tarihi TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
          ''';
          break;

        case 'gunluk_aktivite':
          createTableSQL = '''
          CREATE TABLE public.gunluk_aktivite (
            id SERIAL PRIMARY KEY,
            aktivite_tipi VARCHAR(50) NOT NULL,
            baslik VARCHAR(100) NOT NULL,
            aciklama TEXT,
            baslangic_zamani TIMESTAMP WITH TIME ZONE NOT NULL,
            bitis_zamani TIMESTAMP WITH TIME ZONE,
            durum VARCHAR(20) DEFAULT 'bekliyor',
            kullanici_id INTEGER,
            related_id INTEGER,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
          ''';
          break;

        default:
          print('Unknown table name: $tableName');
          return false;
      }

      // Execute the SQL
      if (createTableSQL.isNotEmpty) {
        final result =
            await callRpc('exec_sql', params: {'query': createTableSQL});
        if (result != null && result['success'] == true) {
          print('Created table: $tableName');
          return true;
        } else {
          print('Error creating table $tableName: ${result ?? "No response"}');
          return false;
        }
      }

      return false;
    } catch (e) {
      print('Error in _createTable: $e');
      return false;
    }
  }

  // Ensure the service is initialized before any operation
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // ==================== CRUD Operations ====================

  // Get data from a table
  Future<List<Map<String, dynamic>>?> getData(
    String table, {
    String? column,
    dynamic value,
    String? select,
    Map<String, dynamic>? eq,
    String? order,
    bool ascending = true,
    int? limit,
    int? offset,
    bool useCache = false,
    String? cacheKey,
  }) async {
    await _ensureInitialized();

    if (_isOfflineMode) return null;

    // Cache check
    if (useCache && cacheKey != null) {
      final cachedData = _getFromCache<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) return cachedData;
    }

    try {
      Uri uri = Uri.parse('$_supabaseUrl/rest/v1/$table');
      final queryParams = <String, String>{};

      // Add select columns
      if (select != null) {
        queryParams['select'] = select;
      }

      // Add equals condition
      if (column != null && value != null) {
        queryParams['$column'] = 'eq.$value';
      }

      // Add multiple equals conditions
      if (eq != null) {
        eq.forEach((key, val) {
          queryParams[key] = 'eq.$val';
        });
      }

      // Add order
      if (order != null) {
        queryParams['order'] = '$order.${ascending ? 'asc' : 'desc'}';
      }

      // Add limit
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      // Add offset
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }

      // Add query params to URI
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = json.decode(response.body);
        final result =
            data.map((item) => Map<String, dynamic>.from(item)).toList();

        // Save to cache
        if (useCache && cacheKey != null) {
          _saveToCache<List<Map<String, dynamic>>>(cacheKey, result);
        }

        return result;
      } else {
        print('Error fetching data from $table: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception fetching data: $e');
      return null;
    }
  }

  // Insert data to a table
  Future<Map<String, dynamic>?> insertData(
    String table,
    Map<String, dynamic> data, {
    String? cacheToClear,
  }) async {
    await _ensureInitialized();

    if (_isOfflineMode) return null;

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/$table'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = json.decode(response.body);

        // Clear cache if needed
        if (cacheToClear != null) {
          _clearCacheByPrefix(cacheToClear);
        }

        return Map<String, dynamic>.from(result[0]);
      } else {
        print('Error inserting data to $table: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception inserting data: $e');
      return null;
    }
  }

  // Update data in a table
  Future<Map<String, dynamic>?> updateData(
    String table,
    dynamic id,
    Map<String, dynamic> data, {
    String idColumn = 'id',
    String? cacheToClear,
  }) async {
    await _ensureInitialized();

    if (_isOfflineMode) return null;

    try {
      final response = await http.patch(
        Uri.parse('$_supabaseUrl/rest/v1/$table?$idColumn=eq.$id'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = json.decode(response.body);

        // Clear cache if needed
        if (cacheToClear != null) {
          _clearCacheByPrefix(cacheToClear);
        }

        return Map<String, dynamic>.from(result[0]);
      } else {
        print('Error updating data in $table: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception updating data: $e');
      return null;
    }
  }

  // Delete data from a table
  Future<bool> deleteData(
    String table,
    dynamic id, {
    String idColumn = 'id',
    String? cacheToClear,
  }) async {
    await _ensureInitialized();

    if (_isOfflineMode) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_supabaseUrl/rest/v1/$table?$idColumn=eq.$id'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Clear cache if needed
        if (cacheToClear != null) {
          _clearCacheByPrefix(cacheToClear);
        }

        return true;
      } else {
        print('Error deleting data from $table: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception deleting data: $e');
      return false;
    }
  }

  // ==================== Cache Management ====================

  // Simple cache mechanism
  T? _getFromCache<T>(String key) {
    if (_cache.containsKey(key)) {
      final cachedData = _cache[key];
      final expiryTime = cachedData['expiry'] as DateTime;

      if (DateTime.now().isBefore(expiryTime)) {
        return cachedData['data'] as T;
      } else {
        // Cache expired, remove it
        _cache.remove(key);
      }
    }
    return null;
  }

  void _saveToCache<T>(String key, T data, {Duration? expiry}) {
    final expiryTime = DateTime.now().add(expiry ?? Duration(minutes: 15));
    _cache[key] = {
      'data': data,
      'expiry': expiryTime,
    };
  }

  void _clearCacheByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  void clearAllCache() {
    _cache.clear();
  }

  // Helpers
  void setOfflineMode(bool value) {
    _isOfflineMode = value;
  }

  bool get isOfflineMode => _isOfflineMode;
  bool get isInitialized => _isInitialized;

  // Provide a supabase getter for compatibility with legacy code
  dynamic get supabase {
    // This is a stub to maintain compatibility with legacy code
    // It returns a proxy object that logs method calls and returns null
    return _SupabaseProxy();
  }
}

// Helper class to handle supabase getter calls
class _SupabaseProxy {
  dynamic noSuchMethod(Invocation invocation) {
    print(
        'Warning: Legacy supabase method ${invocation.memberName} called on SupabaseRestService');
    return null;
  }
}
