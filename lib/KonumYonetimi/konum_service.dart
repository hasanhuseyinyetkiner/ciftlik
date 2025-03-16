import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// API Servisleri
class KonumApiService {
  static const String baseUrl = "https://api.example.com"; // API adresinizi girin

  static Future<List<Map<String, dynamic>>> fetchAnimalLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/konum'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final List<double> coords = (item['konum_geom']['coordinates'] as List)
              .map((e) => e as double)
              .toList();
          return {
            'id': item['konum_id'].toString(),
            'hayvanId': item['hayvan_id'].toString(),
            'konum': LatLng(coords[1], coords[0]),
            'sonGuncelleme': DateTime.parse(item['konum_zamani']),
          };
        }).toList();
      } else {
        throw Exception('Hayvan konum verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchAnimalLocations hatası: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFarmAreas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sanal_cit'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final List<List<double>> coords = (item['geometri']['coordinates'][0] as List)
              .map<List<double>>((point) => (point as List).map((e) => e as double).toList())
              .toList();
          final polygon = coords.map((point) => LatLng(point[1], point[0])).toList();
          return {
            'id': item['cit_id'].toString(),
            'ad': item['cit_adi'],
            'tur': item['uyari_turu'],
            'koordinatlar': polygon,
          };
        }).toList();
      } else {
        throw Exception('Çiftlik alan verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchFarmAreas hatası: $e');
      return [];
    }
  }

  static Future<bool> addAnimalLocation(Map<String, dynamic> location) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/konum'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'hayvan_id': int.parse(location['hayvanId']),
          'konum_geom': {
            'type': 'Point',
            'coordinates': [location['konum'].longitude, location['konum'].latitude]
          },
          'konum_zamani': location['sonGuncelleme'].toIso8601String(),
          'kaynak': 'manuel',
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('addAnimalLocation hatası: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchBarns() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ahir'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
              'id': item['ahir_id'],
              'name': item['name'],
            }).toList();
      } else {
        throw Exception('Ahır verileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchBarns hatası: $e');
      return [];
    }
  }

  // Diğer API metotları (güncelleme, silme, bölme işlemleri) benzer yapıda eklenebilir.
}

/// Yerel Veritabanı Yardımcısı
class DatabaseKonumHelper {
  static final DatabaseKonumHelper instance = DatabaseKonumHelper._();
  static Database? _db;
  DatabaseKonumHelper._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'merlab.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ahir (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bolme (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ahirId INTEGER,
            name TEXT,
            FOREIGN KEY (ahirId) REFERENCES ahir (id)
          )
        ''');
      },
    );
  }

  Future<int> addAhir(String name) async {
    final db = await database;
    return await db.insert('ahir', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAhirList() async {
    final db = await database;
    return await db.query('ahir');
  }

  // updateAhir, removeAhir, addBolme, getBolmeList, removeBolme metotları da buraya eklenebilir.
}

/// GetX Kontrolcüsü: KonumController
class KonumController extends GetxController {
  // Merkezi konum (örneğin çiftliğin merkezi)
  final Rx<LatLng> merkezKonum = LatLng(39.9334, 32.8597).obs;
  final RxList<Map<String, dynamic>> hayvanKonumlari = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> ciftlikAlanlari = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> ahirList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> bolmeList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    _simulateKonumUpdates();
  }

  void loadInitialData() async {
    isLoading.value = true;
    hayvanKonumlari.assignAll(await KonumApiService.fetchAnimalLocations());
    ciftlikAlanlari.assignAll(await KonumApiService.fetchFarmAreas());
    ahirList.assignAll(await DatabaseKonumHelper.instance.getAhirList());
    // Bölme verileri de benzer şekilde yüklenecek.
    isLoading.value = false;
  }

  // Her 30 saniyede hayvan konumlarını rastgele günceller (simülasyon)
  void _simulateKonumUpdates() {
    Future.delayed(Duration(seconds: 30), () {
      for (var i = 0; i < hayvanKonumlari.length; i++) {
        final loc = hayvanKonumlari[i];
        final random = Random();
        final newLat = loc['konum'].latitude + (random.nextDouble() - 0.5) * 0.0001;
        final newLon = loc['konum'].longitude + (random.nextDouble() - 0.5) * 0.0001;
        hayvanKonumlari[i] = {
          ...loc,
          'konum': LatLng(newLat, newLon),
          'sonGuncelleme': DateTime.now(),
        };
      }
      hayvanKonumlari.refresh();
      _simulateKonumUpdates();
    });
  }

  Future<bool> addAnimalKonum(Map<String, dynamic> yeniKonum) async {
    bool success = await KonumApiService.addAnimalLocation(yeniKonum);
    if (success) loadInitialData();
    return success;
  }

  // Ahır ve bölme ekleme/güncelleme metotları da eklenebilir.
}
