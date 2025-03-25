import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'adapter.dart';

void main() async {
  print('Supabase Adaptör Test Programı');
  print('-------------------------------');

  // .env dosyasından Supabase kimlik bilgilerini oku
  Map<String, String> env = {};
  final envFile = File('.env');
  if (await envFile.exists()) {
    final lines = await envFile.readAsLines();
    for (var line in lines) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          env[parts[0]] = parts.sublist(1).join('=');
        }
      }
    }
  }

  final supabaseUrl = env['SUPABASE_URL'] ?? '';
  final supabaseKey = env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('Hata: SUPABASE_URL ve SUPABASE_ANON_KEY değerleri gerekli.');
    print('.env dosyasının doğru yapılandırıldığından emin olun.');
    exit(1);
  }

  print('Supabase URL: $supabaseUrl');
  print('API Key: ${supabaseKey.substring(0, 10)}...');

  // Adaptör sınıfını oluştur
  final adapter = SupabaseAdapter(
    supabaseUrl: supabaseUrl,
    supabaseKey: supabaseKey,
  );

  // Test fonksiyonlarını çalıştır
  await testPing(adapter);
  await testListTables(adapter);
  await testGetHayvanlar(adapter);
  await testAddHayvan(adapter);
  await testGetSutUretim(adapter);
  await testAddSutUretim(adapter);
  await testGetAsiKayitlari(adapter);
  await testAddAsiKaydi(adapter);

  print('\nTüm testler tamamlandı!');
}

// Ping testi
Future<void> testPing(SupabaseAdapter adapter) async {
  print('\n[TEST] Ping Fonksiyonu');
  try {
    final result = await adapter.ping();
    if (result['success'] == true) {
      print('✅ Ping başarılı: ${result['message']}');
    } else {
      print('❌ Ping başarısız: ${result['message']}');
    }
  } catch (e) {
    print('❌ Ping hatası: $e');
  }
}

// Tablo listeleme testi
Future<void> testListTables(SupabaseAdapter adapter) async {
  print('\n[TEST] Tablo Listeleme');
  try {
    final tables = await adapter.listTables();
    if (tables.isNotEmpty) {
      print('✅ Tablolar listelendi:');
      for (var table in tables) {
        print('  - $table');
      }
    } else {
      print('❌ Hiç tablo bulunamadı');
    }
  } catch (e) {
    print('❌ Tablo listeleme hatası: $e');
  }
}

// Hayvanları getirme testi
Future<void> testGetHayvanlar(SupabaseAdapter adapter) async {
  print('\n[TEST] Hayvanları Getirme');
  try {
    // Direkt API isteği yapalım
    final response = await http.get(
      Uri.parse('${adapter.supabaseUrl}/rest/v1/hayvan?select=*'),
      headers: {
        'apikey': adapter.supabaseKey,
        'Authorization': 'Bearer ${adapter.supabaseKey}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> hayvanlar = jsonDecode(response.body);
      if (hayvanlar.isNotEmpty) {
        print('✅ Hayvanlar getirildi (${hayvanlar.length} adet):');
        for (var hayvan in hayvanlar.take(3)) {
          print('  - ${hayvan['kupeno']} (${hayvan['isim']})');
        }
        if (hayvanlar.length > 3) {
          print('  - ... ve ${hayvanlar.length - 3} hayvan daha');
        }
      } else {
        print('ℹ️ Hiç hayvan kaydı bulunamadı');
      }
    } else {
      print('❌ Hayvanlar alınamadı: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ Hayvanları getirme hatası: $e');
  }
}

// Hayvan ekleme testi
Future<void> testAddHayvan(SupabaseAdapter adapter) async {
  print('\n[TEST] Hayvan Ekleme');
  try {
    final testHayvan = {
      'kupeno': 'TEST${DateTime.now().millisecondsSinceEpoch}',
      'isim': 'İnek',
      'cinsiyet': 'Dişi',
      'dogum_tarihi': DateTime.now().toIso8601String(),
      'aktif_mi': true,
    };

    print('Ekleniyor: ${testHayvan['kupeno']}');

    // REST API'ye direkt erişim yapalım
    final response = await http.post(
      Uri.parse('${adapter.supabaseUrl}/rest/v1/hayvan'),
      headers: adapter.headers,
      body: jsonEncode(testHayvan),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic eklenenHayvan = jsonDecode(response.body);
      print('✅ Hayvan eklendi:');
      print('  - ID: ${eklenenHayvan['hayvan_id']}');
      print('  - Küpe No: ${eklenenHayvan['kupeno']}');
      print('  - Tür: ${eklenenHayvan['isim']}');

      // Eklenen hayvanı silme işlemi
      try {
        final hayvanId = eklenenHayvan['hayvan_id'];
        if (hayvanId != null) {
          final silmeResponse = await http.delete(
            Uri.parse(
                '${adapter.supabaseUrl}/rest/v1/hayvan?hayvan_id=eq.$hayvanId'),
            headers: adapter.headers,
          );

          if (silmeResponse.statusCode >= 200 &&
              silmeResponse.statusCode < 300) {
            print('✅ Test hayvanı silindi');
          } else {
            print(
                '⚠️ Test hayvanı silinemedi! (${silmeResponse.statusCode}) - ${silmeResponse.body}');
          }
        }
      } catch (silmeHatasi) {
        print('⚠️ Test hayvanı silinirken hata: $silmeHatasi');
      }
    } else {
      print('❌ Hayvan eklenemedi: (${response.statusCode}) - ${response.body}');
    }
  } catch (e) {
    print('❌ Hayvan ekleme hatası: $e');
  }
}

// Süt üretim verilerini getirme testi
Future<void> testGetSutUretim(SupabaseAdapter adapter) async {
  print('\n[TEST] Süt Üretim Verilerini Getirme');
  try {
    // Direkt API isteği yapalım
    final response = await http.get(
      Uri.parse('${adapter.supabaseUrl}/rest/v1/sut_miktari?select=*'),
      headers: {
        'apikey': adapter.supabaseKey,
        'Authorization': 'Bearer ${adapter.supabaseKey}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> sutVerileri = jsonDecode(response.body);
      if (sutVerileri.isNotEmpty) {
        print('✅ Süt üretim verileri getirildi (${sutVerileri.length} adet):');
        for (var veri in sutVerileri.take(3)) {
          print(
              '  - Hayvan ID: ${veri['hayvan_id']}, Tarih: ${veri['sagim_tarihi']}, Miktar: ${veri['miktar']} litre');
        }
        if (sutVerileri.length > 3) {
          print('  - ... ve ${sutVerileri.length - 3} kayıt daha');
        }
      } else {
        print('ℹ️ Hiç süt üretim verisi bulunamadı');
      }
    } else {
      print(
          '❌ Süt üretim verileri alınamadı: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ Süt üretim verilerini getirme hatası: $e');
  }
}

// Süt üretim verisi ekleme testi
Future<void> testAddSutUretim(SupabaseAdapter adapter) async {
  print('\n[TEST] Süt Üretim Verisi Ekleme');

  try {
    // Önce mevcut bir hayvan ID'si bulalım
    final hayvanResponse = await http.get(
      Uri.parse(
          '${adapter.supabaseUrl}/rest/v1/hayvan?select=hayvan_id&limit=1'),
      headers: {
        'apikey': adapter.supabaseKey,
        'Authorization': 'Bearer ${adapter.supabaseKey}',
      },
    );

    if (hayvanResponse.statusCode != 200 || hayvanResponse.body == '[]') {
      print('ℹ️ Süt üretim testi için hayvan kaydı bulunamadı');
      return;
    }

    final List<dynamic> hayvanlar = jsonDecode(hayvanResponse.body);
    final hayvanId = hayvanlar.first['hayvan_id'];

    final sutVerisi = {
      'hayvan_id': hayvanId,
      'sagim_tarihi': DateTime.now().toIso8601String(),
      'miktar': 5.5,
      'yontem': 'Test verisi',
    };

    print('Süt üretim verisi ekleniyor - Hayvan ID: $hayvanId');

    // Direkt API çağrısı yapalım
    final response = await http.post(
      Uri.parse('${adapter.supabaseUrl}/rest/v1/sut_miktari'),
      headers: adapter.headers,
      body: jsonEncode(sutVerisi),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final eklenenVeri = jsonDecode(response.body);
      print('✅ Süt üretim verisi eklendi:');
      print('  - ID: ${eklenenVeri['sut_miktari_id']}');
      print('  - Tarih: ${eklenenVeri['sagim_tarihi']}');
      print('  - Miktar: ${eklenenVeri['miktar']} litre');
    } else {
      print(
          '❌ Süt üretim verisi eklenemedi: (${response.statusCode}) - ${response.body}');
    }
  } catch (e) {
    print('❌ Süt üretim verisi ekleme hatası: $e');
  }
}

// Aşı kayıtlarını getirme testi
Future<void> testGetAsiKayitlari(SupabaseAdapter adapter) async {
  print('\n[TEST] Aşı Kayıtlarını Getirme');
  try {
    // Direkt API isteği yapalım
    final response = await http.get(
      Uri.parse('${adapter.supabaseUrl}/rest/v1/asilama?select=*,asi(*)'),
      headers: {
        'apikey': adapter.supabaseKey,
        'Authorization': 'Bearer ${adapter.supabaseKey}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> asiKayitlari = jsonDecode(response.body);
      if (asiKayitlari.isNotEmpty) {
        print('✅ Aşı kayıtları getirildi (${asiKayitlari.length} adet):');
        for (var kayit in asiKayitlari.take(3)) {
          String asiAdi = 'Bilinmiyor';
          if (kayit['asi'] != null && kayit['asi']['asi_adi'] != null) {
            asiAdi = kayit['asi']['asi_adi'];
          }
          print(
              '  - Hayvan ID: ${kayit['hayvan_id']}, Aşı: $asiAdi, Tarih: ${kayit['uygulama_tarihi']}');
        }
        if (asiKayitlari.length > 3) {
          print('  - ... ve ${asiKayitlari.length - 3} kayıt daha');
        }
      } else {
        print('ℹ️ Hiç aşı kaydı bulunamadı');
      }
    } else {
      print(
          '❌ Aşı kayıtları alınamadı: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ Aşı kayıtlarını getirme hatası: $e');
  }
}

// Aşı kaydı ekleme testi
Future<void> testAddAsiKaydi(SupabaseAdapter adapter) async {
  print('\n[TEST] Aşı Kaydı Ekleme');

  try {
    // Önce mevcut bir hayvan ID'si bulalım
    final hayvanResponse = await http.get(
      Uri.parse(
          '${adapter.supabaseUrl}/rest/v1/hayvan?select=hayvan_id&limit=1'),
      headers: {
        'apikey': adapter.supabaseKey,
        'Authorization': 'Bearer ${adapter.supabaseKey}',
      },
    );

    if (hayvanResponse.statusCode != 200 || hayvanResponse.body == '[]') {
      print('ℹ️ Aşı kaydı testi için hayvan kaydı bulunamadı');
      return;
    }

    final List<dynamic> hayvanlar = jsonDecode(hayvanResponse.body);
    final hayvanId = hayvanlar.first['hayvan_id'];

    // Önce bir aşı kaydı oluşturalım (yoksa)
    final asiAdi = 'Şap Aşısı';
    int? asiId;

    final asiResponse = await http.get(
      Uri.parse('${adapter.supabaseUrl}/rest/v1/asi?asi_adi=eq.$asiAdi'),
      headers: {
        'apikey': adapter.supabaseKey,
        'Authorization': 'Bearer ${adapter.supabaseKey}',
      },
    );

    if (asiResponse.statusCode == 200) {
      final List<dynamic> asiler = jsonDecode(asiResponse.body);
      if (asiler.isNotEmpty) {
        asiId = asiler.first['asi_id'];
        print('Mevcut aşı bulundu - ID: $asiId');
      } else {
        // Aşı yoksa yeni oluştur
        final yeniAsiResponse = await http.post(
          Uri.parse('${adapter.supabaseUrl}/rest/v1/asi'),
          headers: adapter.headers,
          body: jsonEncode({'asi_adi': asiAdi}),
        );

        if (yeniAsiResponse.statusCode < 200 ||
            yeniAsiResponse.statusCode >= 300) {
          print(
              '❌ Aşı tipi oluşturulamadı: (${yeniAsiResponse.statusCode}) - ${yeniAsiResponse.body}');
          return;
        }

        final yeniAsi = jsonDecode(yeniAsiResponse.body);
        asiId = yeniAsi['asi_id'];
        print('Yeni aşı oluşturuldu - ID: $asiId');
      }

      if (asiId == null) {
        print('❌ Aşı ID alınamadı');
        return;
      }

      final asilamaData = {
        'hayvan_id': hayvanId,
        'asi_id': asiId,
        'uygulama_tarihi': DateTime.now().toIso8601String(),
        'doz_miktari': 5.0,
        'asilama_durumu': 'Tamamlandı',
      };

      print('Aşı kaydı ekleniyor - Hayvan ID: $hayvanId, Aşı ID: $asiId');

      // Şimdi aşılama kaydını oluşturalım
      final asilamaResponse = await http.post(
        Uri.parse('${adapter.supabaseUrl}/rest/v1/asilama'),
        headers: adapter.headers,
        body: jsonEncode(asilamaData),
      );

      if (asilamaResponse.statusCode >= 200 &&
          asilamaResponse.statusCode < 300) {
        final eklenenVeri = jsonDecode(asilamaResponse.body);
        print('✅ Aşı kaydı eklendi:');
        print('  - ID: ${eklenenVeri['asilama_id']}');
        print('  - Aşı: $asiAdi');
        print('  - Tarih: ${eklenenVeri['uygulama_tarihi']}');
        print('  - Doz: ${eklenenVeri['doz_miktari']}');
      } else {
        print(
            '❌ Aşı kaydı eklenemedi: (${asilamaResponse.statusCode}) - ${asilamaResponse.body}');
      }
    } else {
      print(
          '❌ Aşı bilgisi alınamadı: (${asiResponse.statusCode}) - ${asiResponse.body}');
    }
  } catch (e) {
    print('❌ Aşı kaydı ekleme hatası: $e');
  }
}
