import 'dart:convert';
import 'package:http/http.dart' as http;

/// Supabase Adaptör Sınıfı
/// Bu sınıf, uygulamanın beklediği veri modeli ile Supabase'deki mevcut veri modeli
/// arasında dönüşüm yaparak uyumluluğu sağlar.
class SupabaseAdapter {
  final String supabaseUrl;
  final String supabaseKey;

  SupabaseAdapter({required this.supabaseUrl, required this.supabaseKey});

  // HTTP İstek başlıkları
  Map<String, String> get headers => {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  /// Ping fonksiyonu adaptörü
  /// `hayvanlar` tablosunun olmadığı durumlarda bile çalışır
  Future<Map<String, dynamic>> ping() async {
    try {
      // Basit bir REST API testi yapalım
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'pong'};
      } else {
        return {
          'success': false,
          'message': 'Bağlantı hatası: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Hata: $e'};
    }
  }

  /// Tablo listeleme adaptörü
  /// Mevcut tabloları döndürür
  Future<List<String>> listTables() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final tables = data.keys
            .where((key) =>
                !key.startsWith('rpc/') && !key.startsWith('extensions/'))
            .toList();
        return tables;
      } else {
        return [];
      }
    } catch (e) {
      print('Tablo listeleme hatası: $e');
      return [];
    }
  }

  /// Hayvan ekleme adaptörü
  /// `hayvan` tablosuna veri ekler, ancak uygulamanın beklediği `hayvanlar` modeline uygun döner
  Future<Map<String, dynamic>> addHayvan(
      Map<String, dynamic> hayvanData) async {
    try {
      // Gelen veriyi `hayvan` tablosuna uygun formata dönüştür
      final hayvanTableData = {
        'isim': hayvanData['tur'] ?? 'Yeni Hayvan',
        'kupeno': hayvanData['kupe_no'],
        'cinsiyet': hayvanData['cinsiyet'],
        'dogum_tarihi': hayvanData['dogum_tarihi'],
        'aktif_mi': true,
      };

      // `hayvan` tablosuna ekle
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/hayvan'),
        headers: headers,
        body: jsonEncode(hayvanTableData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic eklenenHayvan = jsonDecode(response.body);

        // Eğer dönen değer bir liste ise ilk elemanı al
        final hayvan =
            eklenenHayvan is List ? eklenenHayvan.first : eklenenHayvan;

        // Eklenen hayvanı `hayvanlar` formatına dönüştür
        return {
          'id': hayvan['hayvan_id'] is int
              ? hayvan['hayvan_id']
              : int.tryParse(hayvan['hayvan_id'].toString()) ?? 0,
          'kupe_no': hayvan['kupeno']?.toString() ?? '',
          'tur': hayvan['isim']?.toString() ?? '',
          'irk': hayvan['irk']?.toString() ?? '',
          'cinsiyet': hayvan['cinsiyet']?.toString() ?? '',
          'dogum_tarihi': hayvan['dogum_tarihi']?.toString() ?? '',
          'durum': hayvan['aktif_mi'] == true ? 'Aktif' : 'Pasif',
          'created_at': hayvan['created_at']?.toString() ??
              DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Hayvan eklenirken hata: ${response.body}');
      }
    } catch (e) {
      print('Hayvan ekleme hatası: $e');
      rethrow;
    }
  }

  /// Hayvan listesi adaptörü
  /// `hayvan` tablosundan veri çeker, ancak uygulamanın beklediği `hayvanlar` formatına dönüştürür
  Future<List<Map<String, dynamic>>> getHayvanlar() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/hayvan?select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> hayvanlar = jsonDecode(response.body);

        // `hayvan` tablosundan gelen verileri `hayvanlar` formatına dönüştür
        return hayvanlar
            .map((dynamic hayvan) => {
                  'id': hayvan['hayvan_id'] is int
                      ? hayvan['hayvan_id']
                      : int.tryParse(hayvan['hayvan_id'].toString()) ?? 0,
                  'kupe_no': hayvan['kupeno']?.toString() ?? '',
                  'tur': hayvan['isim']?.toString() ?? '',
                  'irk': hayvan['irk']?.toString() ?? '',
                  'cinsiyet': hayvan['cinsiyet']?.toString() ?? '',
                  'dogum_tarihi': hayvan['dogum_tarihi']?.toString() ?? '',
                  'durum': hayvan['aktif_mi'] == true ? 'Aktif' : 'Pasif',
                  'created_at': hayvan['created_at']?.toString() ?? '',
                })
            .toList();
      } else {
        throw Exception('Hayvanlar alınırken hata: ${response.body}');
      }
    } catch (e) {
      print('Hayvanlar listesi hatası: $e');
      return [];
    }
  }

  /// Hayvan detayı adaptörü
  /// `hayvan` tablosundan bir hayvanı ID'ye göre çeker
  Future<Map<String, dynamic>?> getHayvanById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/hayvan?hayvan_id=eq.$id'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> hayvanlar = jsonDecode(response.body);
        if (hayvanlar.isEmpty) return null;

        final dynamic hayvan = hayvanlar.first;

        // `hayvan` tablosundan gelen veriyi `hayvanlar` formatına dönüştür
        return {
          'id': hayvan['hayvan_id'] is int
              ? hayvan['hayvan_id']
              : int.tryParse(hayvan['hayvan_id'].toString()) ?? 0,
          'kupe_no': hayvan['kupeno']?.toString() ?? '',
          'tur': hayvan['isim']?.toString() ?? '',
          'irk': hayvan['irk']?.toString() ?? '',
          'cinsiyet': hayvan['cinsiyet']?.toString() ?? '',
          'dogum_tarihi': hayvan['dogum_tarihi']?.toString() ?? '',
          'durum': hayvan['aktif_mi'] == true ? 'Aktif' : 'Pasif',
          'created_at': hayvan['created_at']?.toString() ?? '',
        };
      } else {
        throw Exception('Hayvan detayı alınırken hata: ${response.body}');
      }
    } catch (e) {
      print('Hayvan detayı hatası: $e');
      return null;
    }
  }

  /// Hayvan silme adaptörü
  Future<bool> deleteHayvan(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$supabaseUrl/rest/v1/hayvan?hayvan_id=eq.$id'),
        headers: headers,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Hayvan silme hatası: $e');
      return false;
    }
  }

  /// Hayvan güncelleme adaptörü
  Future<Map<String, dynamic>?> updateHayvan(
      String id, Map<String, dynamic> hayvanData) async {
    try {
      // Gelen veriyi `hayvan` tablosuna uygun formata dönüştür
      final hayvanTableData = {
        'isim': hayvanData['tur']?.toString(),
        'kupeno': hayvanData['kupe_no']?.toString(),
        'cinsiyet': hayvanData['cinsiyet']?.toString(),
        'dogum_tarihi': hayvanData['dogum_tarihi']?.toString(),
        'irk': hayvanData['irk']?.toString(),
        'aktif_mi': hayvanData['durum'] == 'Aktif',
      };

      final response = await http.patch(
        Uri.parse('$supabaseUrl/rest/v1/hayvan?hayvan_id=eq.$id'),
        headers: headers,
        body: jsonEncode(hayvanTableData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return getHayvanById(id);
      } else {
        throw Exception('Hayvan güncellenirken hata: ${response.body}');
      }
    } catch (e) {
      print('Hayvan güncelleme hatası: $e');
      return null;
    }
  }

  /// Süt üretim verilerini `sut_miktari` tablosundan alır
  Future<List<Map<String, dynamic>>> getSutUretim() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/sut_miktari?select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> sutVerileri = jsonDecode(response.body);

        // `sut_miktari` tablosundan gelen verileri `sut_uretim` formatına dönüştür
        return sutVerileri
            .map((dynamic veri) => {
                  'id': veri['sut_miktari_id'] is int
                      ? veri['sut_miktari_id']
                      : int.tryParse(veri['sut_miktari_id'].toString()) ?? 0,
                  'hayvan_id': veri['hayvan_id'] is int
                      ? veri['hayvan_id']
                      : int.tryParse(veri['hayvan_id'].toString()) ?? 0,
                  'tarih': veri['sagim_tarihi']?.toString() ?? '',
                  'miktar_litre': veri['miktar'] is num
                      ? veri['miktar']
                      : double.tryParse(veri['miktar'].toString()) ?? 0.0,
                  'created_at': veri['created_at']?.toString() ?? '',
                })
            .toList();
      } else {
        throw Exception('Süt üretim verileri alınırken hata: ${response.body}');
      }
    } catch (e) {
      print('Süt üretim verileri hatası: $e');
      return [];
    }
  }

  /// Süt üretim verisi ekleme
  Future<Map<String, dynamic>?> addSutUretim(
      Map<String, dynamic> sutData) async {
    try {
      // Gelen veriyi `sut_miktari` tablosuna uygun formata dönüştür
      final hayvanId = sutData['hayvan_id'] is int
          ? sutData['hayvan_id']
          : int.tryParse(sutData['hayvan_id'].toString()) ?? 0;

      final miktar = sutData['miktar_litre'] is num
          ? sutData['miktar_litre']
          : double.tryParse(sutData['miktar_litre'].toString()) ?? 0.0;

      final sutTableData = {
        'hayvan_id': hayvanId,
        'sagim_tarihi': sutData['tarih']?.toString(),
        'miktar': miktar,
        'yontem': sutData['not']?.toString() ?? 'Manuel',
      };

      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/sut_miktari'),
        headers: headers,
        body: jsonEncode(sutTableData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic eklenenVeri = jsonDecode(response.body);

        // Eğer dönen değer bir liste ise ilk elemanı al
        final veri = eklenenVeri is List ? eklenenVeri.first : eklenenVeri;

        return {
          'id': veri['sut_miktari_id'] is int
              ? veri['sut_miktari_id']
              : int.tryParse(veri['sut_miktari_id'].toString()) ?? 0,
          'hayvan_id': veri['hayvan_id'] is int
              ? veri['hayvan_id']
              : int.tryParse(veri['hayvan_id'].toString()) ?? 0,
          'tarih': veri['sagim_tarihi']?.toString() ?? '',
          'miktar_litre': veri['miktar'] is num
              ? veri['miktar']
              : double.tryParse(veri['miktar'].toString()) ?? 0.0,
          'created_at': veri['created_at']?.toString() ??
              DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Süt üretim verisi eklenirken hata: ${response.body}');
      }
    } catch (e) {
      print('Süt üretim verisi ekleme hatası: $e');
      return null;
    }
  }

  /// Aşı verilerini `asilama` tablosundan alır
  Future<List<Map<String, dynamic>>> getAsiKayitlari() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/asilama?select=*,asi(*)'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> asiVerileri = jsonDecode(response.body);

        // `asilama` tablosundan gelen verileri `asi_kayitlari` formatına dönüştür
        return asiVerileri
            .map((dynamic veri) => {
                  'id': veri['asilama_id'] is int
                      ? veri['asilama_id']
                      : int.tryParse(veri['asilama_id'].toString()) ?? 0,
                  'hayvan_id': veri['hayvan_id'] is int
                      ? veri['hayvan_id']
                      : int.tryParse(veri['hayvan_id'].toString()) ?? 0,
                  'asi_tarihi': veri['uygulama_tarihi']?.toString() ?? '',
                  'asi_turu': veri['asi'] != null
                      ? veri['asi']['asi_adi']?.toString() ?? 'Bilinmiyor'
                      : 'Bilinmiyor',
                  'doz': veri['doz_miktari'] != null
                      ? veri['doz_miktari'].toString()
                      : '0',
                  'yapan_kisi': 'Veteriner',
                  'created_at': veri['created_at']?.toString() ?? '',
                })
            .toList();
      } else {
        throw Exception('Aşı kayıtları alınırken hata: ${response.body}');
      }
    } catch (e) {
      print('Aşı kayıtları hatası: $e');
      return [];
    }
  }

  /// Aşı verisi ekleme
  Future<Map<String, dynamic>?> addAsiKaydi(
      Map<String, dynamic> asiData) async {
    try {
      // Önce uygun bir aşı ID'si bulalım veya yeni bir aşı oluşturalım
      int asiId;
      final asiAdi = asiData['asi_turu']?.toString() ?? 'Bilinmeyen Aşı';

      // Aşı adına göre arama yap
      final asiResponse = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/asi?asi_adi=eq.$asiAdi'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (asiResponse.statusCode == 200) {
        final List<dynamic> asiler = jsonDecode(asiResponse.body);
        if (asiler.isNotEmpty) {
          final dynamic asi = asiler.first;
          asiId = asi['asi_id'] is int
              ? asi['asi_id']
              : int.tryParse(asi['asi_id'].toString()) ?? 0;
        } else {
          // Aşı yoksa yeni oluştur
          final yeniAsiResponse = await http.post(
            Uri.parse('$supabaseUrl/rest/v1/asi'),
            headers: headers,
            body: jsonEncode({'asi_adi': asiAdi}),
          );

          if (yeniAsiResponse.statusCode >= 200 &&
              yeniAsiResponse.statusCode < 300) {
            final dynamic yeniAsiData = jsonDecode(yeniAsiResponse.body);
            // Eğer dönen değer bir liste ise ilk elemanı al
            final yeniAsi =
                yeniAsiData is List ? yeniAsiData.first : yeniAsiData;

            asiId = yeniAsi['asi_id'] is int
                ? yeniAsi['asi_id']
                : int.tryParse(yeniAsi['asi_id'].toString()) ?? 0;
          } else {
            throw Exception(
                'Aşı tipi oluşturulurken hata: ${yeniAsiResponse.body}');
          }
        }

        // Hayvan ID'yi uygun formata dönüştür
        final hayvanId = asiData['hayvan_id'] is int
            ? asiData['hayvan_id']
            : int.tryParse(asiData['hayvan_id'].toString()) ?? 0;

        // Doz miktarını uygun formata dönüştür
        final dozMiktari =
            double.tryParse(asiData['doz']?.toString() ?? '0') ?? 0.0;

        // Şimdi aşılama kaydını oluştur
        final asilamaData = {
          'hayvan_id': hayvanId,
          'asi_id': asiId,
          'uygulama_tarihi': asiData['asi_tarihi']?.toString() ??
              DateTime.now().toIso8601String(),
          'doz_miktari': dozMiktari,
          'asilama_durumu': 'Tamamlandı',
        };

        final asilamaResponse = await http.post(
          Uri.parse('$supabaseUrl/rest/v1/asilama'),
          headers: headers,
          body: jsonEncode(asilamaData),
        );

        if (asilamaResponse.statusCode >= 200 &&
            asilamaResponse.statusCode < 300) {
          final dynamic eklenenVeriData = jsonDecode(asilamaResponse.body);
          // Eğer dönen değer bir liste ise ilk elemanı al
          final eklenenVeri =
              eklenenVeriData is List ? eklenenVeriData.first : eklenenVeriData;

          return {
            'id': eklenenVeri['asilama_id'] is int
                ? eklenenVeri['asilama_id']
                : int.tryParse(eklenenVeri['asilama_id'].toString()) ?? 0,
            'hayvan_id': eklenenVeri['hayvan_id'] is int
                ? eklenenVeri['hayvan_id']
                : int.tryParse(eklenenVeri['hayvan_id'].toString()) ?? 0,
            'asi_tarihi': eklenenVeri['uygulama_tarihi']?.toString() ?? '',
            'asi_turu': asiAdi,
            'doz': eklenenVeri['doz_miktari'] != null
                ? eklenenVeri['doz_miktari'].toString()
                : '0',
            'created_at': eklenenVeri['created_at']?.toString() ??
                DateTime.now().toIso8601String(),
          };
        } else {
          throw Exception('Aşı kaydı eklenirken hata: ${asilamaResponse.body}');
        }
      } else {
        throw Exception('Aşı tipi aranırken hata: ${asiResponse.body}');
      }
    } catch (e) {
      print('Aşı kaydı ekleme hatası: $e');
      return null;
    }
  }

  // Generic methods for table operations
  Future<bool> checkRecordExists(String tableName, String id) async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/$tableName?id=eq.$id'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking if record exists in $tableName: $e');
      return false;
    }
  }

  Future<bool> updateRecord(
      String tableName, String id, Map<String, dynamic> data) async {
    try {
      // Remove any null values to avoid overwriting existing data with nulls
      final cleanData = Map<String, dynamic>.from(data);
      cleanData.removeWhere((key, value) => value == null);

      final response = await http.patch(
        Uri.parse('$supabaseUrl/rest/v1/$tableName?id=eq.$id'),
        headers: headers,
        body: jsonEncode(cleanData),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error updating record in $tableName: $e');
      return false;
    }
  }

  Future<bool> insertRecord(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/$tableName'),
        headers: headers,
        body: jsonEncode(data),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error inserting record into $tableName: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getTableData(String tableName) async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/$tableName?select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
            data.map((dynamic d) => Map<String, dynamic>.from(d)));
      }

      return null;
    } catch (e) {
      print('Error fetching data from $tableName: $e');
      return null;
    }
  }

  // Weight-specific methods
  Future<Map<String, dynamic>?> addWeightRecord(
      Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/hayvan_tartimlar'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic eklenenVeri = jsonDecode(response.body);
        if (eklenenVeri is List) {
          return Map<String, dynamic>.from(eklenenVeri.first);
        } else if (eklenenVeri is Map) {
          return Map<String, dynamic>.from(eklenenVeri);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Error adding weight record: ${response.body}');
      }
    } catch (e) {
      print('Error adding weight record: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAnimalWeights(String animalId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$supabaseUrl/rest/v1/hayvan_tartimlar?hayvan_id=eq.$animalId&select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
            data.map((dynamic d) => Map<String, dynamic>.from(d)));
      }

      return null;
    } catch (e) {
      print('Error fetching animal weights: $e');
      return null;
    }
  }

  Future<bool> updateWeightRecord(String id, Map<String, dynamic> data) async {
    return updateRecord('hayvan_tartimlar', id, data);
  }

  Future<bool> deleteWeightRecord(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$supabaseUrl/rest/v1/hayvan_tartimlar?id=eq.$id'),
        headers: headers,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error deleting weight record: $e');
      return false;
    }
  }
}
