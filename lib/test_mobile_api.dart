import 'dart:convert';
import 'dart:io';
import 'adapter.dart';

// Flutter uygulamasının yaptığı API çağrılarını test eden uygulama
void main() async {
  print('⭐️ Flutter API Çağrıları Testi ⭐️');
  print('===============================');

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

  // Adaptör sınıfını oluştur
  final adapter = SupabaseAdapter(
    supabaseUrl: supabaseUrl,
    supabaseKey: supabaseKey,
  );

  // Ana test menüsünü göster
  await runTests(adapter);
}

Future<void> runTests(SupabaseAdapter adapter) async {
  print('\nAPI Test Senaryoları:');
  print('==================');

  // Test 1: Ping
  await testPing(adapter);

  // Test 2: Hayvan Listesi
  await testHayvanListesi(adapter);

  // Test 3: Hayvan Ekleme
  await testHayvanEkleme(adapter);

  // Test 4: Hayvan Güncelleme
  await testHayvanGuncelleme(adapter);

  // Test 5: Süt Üretim Kayıtları
  await testSutUretim(adapter);

  // Test 6: Aşı Kayıtları
  await testAsiKayitlari(adapter);

  print('\n✅ Tüm testler tamamlandı!');
}

// Test 1: Ping
Future<void> testPing(SupabaseAdapter adapter) async {
  print('\n📡 Test 1: Ping');
  print('----------------');

  try {
    final result = await adapter.ping();
    if (result['success'] == true) {
      print('✅ Başarılı: ${result['message']}');
    } else {
      print('❌ Başarısız: ${result['message']}');
    }
  } catch (e) {
    print('❌ Hata: $e');
  }
}

// Test 2: Hayvan Listesi
Future<void> testHayvanListesi(SupabaseAdapter adapter) async {
  print('\n🐄 Test 2: Hayvan Listesi');
  print('------------------------');

  try {
    final hayvanlar = await adapter.getHayvanlar();
    print('✅ Hayvan listesi alındı. Toplam: ${hayvanlar.length} hayvan');

    if (hayvanlar.isNotEmpty) {
      print('\n📋 İlk 3 hayvan:');
      for (var i = 0; i < hayvanlar.length && i < 3; i++) {
        final hayvan = hayvanlar[i];
        print(
            '  🔹 #${i + 1} - ${hayvan['kupe_no']} (${hayvan['tur']}, ${hayvan['cinsiyet']})');
      }
    } else {
      print('⚠️ Hiç hayvan kaydı bulunamadı.');
    }
  } catch (e) {
    print('❌ Hata: $e');
  }
}

// Test 3: Hayvan Ekleme
Future<void> testHayvanEkleme(SupabaseAdapter adapter) async {
  print('\n➕ Test 3: Hayvan Ekleme');
  print('----------------------');

  try {
    // Örnek hayvan verisi
    final hayvanData = {
      'kupe_no': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
      'tur': 'Test Hayvan',
      'cinsiyet': 'Dişi',
      'dogum_tarihi': DateTime.now().toString().split(' ')[0],
    };

    print('📤 Ekleniyor: ${hayvanData['kupe_no']}');
    final result = await adapter.addHayvan(hayvanData);

    print('✅ Hayvan eklendi:');
    print('  🔹 ID: ${result['id']}');
    print('  🔹 Küpe No: ${result['kupe_no']}');
    print('  🔹 Tür: ${result['tur']}');
    print('  🔹 Durum: ${result['durum']}');

    // Eklenen ID'yi kaydet (Test 4 için)
    return result['id'];
  } catch (e) {
    print('❌ Hata: $e');
    return null;
  }
}

// Test 4: Hayvan Güncelleme
Future<void> testHayvanGuncelleme(SupabaseAdapter adapter) async {
  print('\n🔄 Test 4: Hayvan Güncelleme');
  print('--------------------------');

  try {
    // Önce hayvan listesini al
    final hayvanlar = await adapter.getHayvanlar();
    if (hayvanlar.isEmpty) {
      print('⚠️ Güncellenecek hayvan bulunamadı.');
      return;
    }

    // Test için son eklenen hayvanı seç
    final hayvan = hayvanlar.last;
    final hayvanId = hayvan['id'].toString();

    print('📤 Güncelleniyor: ID #$hayvanId (${hayvan['kupe_no']})');

    // Güncelleme verileri
    final updateData = {
      'kupe_no': hayvan['kupe_no'],
      'tur': '${hayvan['tur']} (Güncellendi)',
      'cinsiyet': hayvan['cinsiyet'],
      'dogum_tarihi': hayvan['dogum_tarihi'],
    };

    final result = await adapter.updateHayvan(hayvanId, updateData);

    if (result != null) {
      print('✅ Hayvan güncellendi:');
      print('  🔹 ID: ${result['id']}');
      print('  🔹 Küpe No: ${result['kupe_no']}');
      print('  🔹 Yeni Tür: ${result['tur']}');
    } else {
      print('❌ Güncelleme başarısız.');
    }
  } catch (e) {
    print('❌ Hata: $e');
  }
}

// Test 5: Süt Üretim Kayıtları
Future<void> testSutUretim(SupabaseAdapter adapter) async {
  print('\n🥛 Test 5: Süt Üretim Kayıtları');
  print('-----------------------------');

  try {
    // Süt üretim kayıtlarını al
    final sutKayitlari = await adapter.getSutUretim();
    print(
        '✅ Süt üretim kayıtları alındı. Toplam: ${sutKayitlari.length} kayıt');

    if (sutKayitlari.isNotEmpty) {
      print('\n📋 İlk 3 süt üretim kaydı:');
      for (var i = 0; i < sutKayitlari.length && i < 3; i++) {
        final kayit = sutKayitlari[i];
        print(
            '  🔹 #${i + 1} - Hayvan ID: ${kayit['hayvan_id']}, Miktar: ${kayit['miktar_litre']} litre, Tarih: ${kayit['tarih']}');
      }
    } else {
      print('⚠️ Hiç süt üretim kaydı bulunamadı.');
    }

    // Yeni bir süt üretim kaydı ekle
    try {
      // Hayvanları al
      final hayvanlar = await adapter.getHayvanlar();
      if (hayvanlar.isEmpty) {
        print('⚠️ Süt üretim kaydı eklemek için hayvan bulunamadı.');
        return;
      }

      // İlk hayvanı seç
      final hayvanId = hayvanlar.first['id'];

      // Süt üretim verisi
      final sutData = {
        'hayvan_id': hayvanId,
        'tarih': DateTime.now().toString().split(' ')[0],
        'miktar_litre': 25.5,
        'not': 'Test kaydı',
      };

      print('📤 Süt üretim kaydı ekleniyor: Hayvan ID #$hayvanId');
      final result = await adapter.addSutUretim(sutData);

      if (result != null) {
        print('✅ Süt üretim kaydı eklendi:');
        print('  🔹 ID: ${result['id']}');
        print('  🔹 Hayvan ID: ${result['hayvan_id']}');
        print('  🔹 Miktar: ${result['miktar_litre']} litre');
        print('  🔹 Tarih: ${result['tarih']}');
      } else {
        print('❌ Süt üretim kaydı eklenemedi.');
      }
    } catch (e) {
      print('❌ Süt üretim kaydı eklerken hata: $e');
    }
  } catch (e) {
    print('❌ Hata: $e');
  }
}

// Test 6: Aşı Kayıtları
Future<void> testAsiKayitlari(SupabaseAdapter adapter) async {
  print('\n💉 Test 6: Aşı Kayıtları');
  print('----------------------');

  try {
    // Aşı kayıtlarını al
    final asiKayitlari = await adapter.getAsiKayitlari();
    print('✅ Aşı kayıtları alındı. Toplam: ${asiKayitlari.length} kayıt');

    if (asiKayitlari.isNotEmpty) {
      print('\n📋 İlk 3 aşı kaydı:');
      for (var i = 0; i < asiKayitlari.length && i < 3; i++) {
        final kayit = asiKayitlari[i];
        print(
            '  🔹 #${i + 1} - Hayvan ID: ${kayit['hayvan_id']}, Aşı: ${kayit['asi_turu']}, Tarih: ${kayit['asi_tarihi']}');
      }
    } else {
      print('⚠️ Hiç aşı kaydı bulunamadı.');
    }

    // Yeni bir aşı kaydı ekle
    try {
      // Hayvanları al
      final hayvanlar = await adapter.getHayvanlar();
      if (hayvanlar.isEmpty) {
        print('⚠️ Aşı kaydı eklemek için hayvan bulunamadı.');
        return;
      }

      // İlk hayvanı seç
      final hayvanId = hayvanlar.first['id'];

      // Aşı verisi
      final asiData = {
        'hayvan_id': hayvanId,
        'asi_tarihi': DateTime.now().toString().split(' ')[0],
        'asi_turu': 'Test Aşısı',
        'doz': '2.5',
      };

      print('📤 Aşı kaydı ekleniyor: Hayvan ID #$hayvanId');
      final result = await adapter.addAsiKaydi(asiData);

      if (result != null) {
        print('✅ Aşı kaydı eklendi:');
        print('  🔹 ID: ${result['id']}');
        print('  🔹 Hayvan ID: ${result['hayvan_id']}');
        print('  🔹 Aşı Türü: ${result['asi_turu']}');
        print('  🔹 Tarih: ${result['asi_tarihi']}');
      } else {
        print('❌ Aşı kaydı eklenemedi.');
      }
    } catch (e) {
      print('❌ Aşı kaydı eklerken hata: $e');
    }
  } catch (e) {
    print('❌ Hata: $e');
  }
}
