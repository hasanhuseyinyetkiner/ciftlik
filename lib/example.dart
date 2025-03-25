import 'dart:io';
import 'dart:convert';
import 'adapter.dart';

void main() async {
  print('Çiftlik Yönetim Sistemi');
  print('======================');

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

  // Ana menüyü göster
  await showMenu(adapter);
}

Future<void> showMenu(SupabaseAdapter adapter) async {
  while (true) {
    print('\nAna Menü:');
    print('1. Hayvanları Listele');
    print('2. Hayvan Ekle');
    print('3. Süt Üretim Kayıtlarını Görüntüle');
    print('4. Süt Üretim Kaydı Ekle');
    print('5. Aşı Kayıtlarını Görüntüle');
    print('6. Aşı Kaydı Ekle');
    print('0. Çıkış');

    stdout.write('\nSeçiminiz (0-6): ');
    final selection = stdin.readLineSync() ?? '';

    switch (selection) {
      case '1':
        await listAnimals(adapter);
        break;
      case '2':
        await addAnimal(adapter);
        break;
      case '3':
        await viewMilkProduction(adapter);
        break;
      case '4':
        await addMilkProduction(adapter);
        break;
      case '5':
        await viewVaccineRecords(adapter);
        break;
      case '6':
        await addVaccineRecord(adapter);
        break;
      case '0':
        print('Programdan çıkılıyor...');
        return;
      default:
        print('Geçersiz seçim! Lütfen 0-6 arasında bir değer girin.');
    }
  }
}

// Hayvan Listesi
Future<void> listAnimals(SupabaseAdapter adapter) async {
  print('\n--- Hayvan Listesi ---');
  try {
    final hayvanlar = await adapter.getHayvanlar();
    if (hayvanlar.isEmpty) {
      print('Kayıtlı hayvan bulunamadı.');
      return;
    }

    // Tablo başlığı
    print('-'.padRight(80, '-'));
    print(
        '| ${'ID'.padRight(4)} | ${'Küpe No'.padRight(15)} | ${'Tür'.padRight(10)} | ${'Cinsiyet'.padRight(8)} | ${'Doğum Tarihi'.padRight(20)} | ${'Durum'.padRight(8)} |');
    print('-'.padRight(80, '-'));

    for (var hayvan in hayvanlar) {
      print(
          '| ${hayvan['id'].toString().padRight(4)} | ${hayvan['kupe_no'].toString().padRight(15)} | ${hayvan['tur'].toString().padRight(10)} | ${hayvan['cinsiyet'].toString().padRight(8)} | ${(hayvan['dogum_tarihi'] ?? '').toString().padRight(20)} | ${hayvan['durum'].toString().padRight(8)} |');
    }

    print('-'.padRight(80, '-'));
  } catch (e) {
    print('Hayvanlar listelenirken bir hata oluştu: $e');
  }
}

// Hayvan Ekleme
Future<void> addAnimal(SupabaseAdapter adapter) async {
  print('\n--- Yeni Hayvan Ekle ---');

  stdout.write('Küpe No: ');
  final kupeNo = stdin.readLineSync() ?? '';

  stdout.write('Tür (İnek, Koyun, vb.): ');
  final tur = stdin.readLineSync() ?? '';

  stdout.write('Cinsiyet (Erkek/Dişi): ');
  final cinsiyet = stdin.readLineSync() ?? '';

  stdout.write('Doğum Tarihi (YYYY-MM-DD): ');
  final dogumTarihi = stdin.readLineSync() ?? '';

  try {
    final hayvanData = {
      'kupe_no': kupeNo,
      'tur': tur,
      'cinsiyet': cinsiyet,
      'dogum_tarihi': dogumTarihi,
    };

    print('\nHayvan ekleniyor...');
    final result = await adapter.addHayvan(hayvanData);

    print('\nHayvan başarıyla eklendi!');
    print('ID: ${result['id']}');
    print('Küpe No: ${result['kupe_no']}');
    print('Tür: ${result['tur']}');
    print('Durum: ${result['durum']}');
  } catch (e) {
    print('Hayvan eklenirken bir hata oluştu: $e');
  }
}

// Süt Üretim Kayıtları
Future<void> viewMilkProduction(SupabaseAdapter adapter) async {
  print('\n--- Süt Üretim Kayıtları ---');
  try {
    final records = await adapter.getSutUretim();
    if (records.isEmpty) {
      print('Kayıtlı süt üretim verisi bulunamadı.');
      return;
    }

    // Tablo başlığı
    print('-'.padRight(70, '-'));
    print(
        '| ${'ID'.padRight(4)} | ${'Hayvan ID'.padRight(9)} | ${'Tarih'.padRight(25)} | ${'Miktar (L)'.padRight(15)} |');
    print('-'.padRight(70, '-'));

    for (var record in records) {
      print(
          '| ${record['id'].toString().padRight(4)} | ${record['hayvan_id'].toString().padRight(9)} | ${(record['tarih'] ?? '').toString().padRight(25)} | ${record['miktar_litre'].toString().padRight(15)} |');
    }

    print('-'.padRight(70, '-'));
  } catch (e) {
    print('Süt üretim kayıtları alınırken bir hata oluştu: $e');
  }
}

// Süt Üretim Kaydı Ekleme
Future<void> addMilkProduction(SupabaseAdapter adapter) async {
  print('\n--- Yeni Süt Üretim Kaydı Ekle ---');

  // Önce hayvanları listeleyelim
  try {
    final hayvanlar = await adapter.getHayvanlar();
    if (hayvanlar.isEmpty) {
      print('Kayıtlı hayvan bulunamadı. Önce hayvan eklemelisiniz.');
      return;
    }

    print('\nHayvan Listesi:');
    for (var hayvan in hayvanlar) {
      print(
          'ID: ${hayvan['id']}, Küpe No: ${hayvan['kupe_no']}, Tür: ${hayvan['tur']}');
    }

    stdout.write('\nHayvan ID: ');
    final hayvanId = stdin.readLineSync() ?? '';

    stdout.write('Miktar (Litre): ');
    final miktar = stdin.readLineSync() ?? '';

    stdout.write('Not (opsiyonel): ');
    final not = stdin.readLineSync() ?? '';

    final sutData = {
      'hayvan_id': hayvanId,
      'tarih': DateTime.now().toIso8601String(),
      'miktar_litre': double.tryParse(miktar) ?? 0.0,
      'not': not,
    };

    print('\nSüt üretim kaydı ekleniyor...');
    final result = await adapter.addSutUretim(sutData);

    if (result != null) {
      print('\nSüt üretim kaydı başarıyla eklendi!');
      print('ID: ${result['id']}');
      print('Hayvan ID: ${result['hayvan_id']}');
      print('Tarih: ${result['tarih']}');
      print('Miktar: ${result['miktar_litre']} litre');
    } else {
      print('Süt üretim kaydı eklenemedi.');
    }
  } catch (e) {
    print('Süt üretim kaydı eklenirken bir hata oluştu: $e');
  }
}

// Aşı Kayıtları
Future<void> viewVaccineRecords(SupabaseAdapter adapter) async {
  print('\n--- Aşı Kayıtları ---');
  try {
    final records = await adapter.getAsiKayitlari();
    if (records.isEmpty) {
      print('Kayıtlı aşı verisi bulunamadı.');
      return;
    }

    // Tablo başlığı
    print('-'.padRight(85, '-'));
    print(
        '| ${'ID'.padRight(4)} | ${'Hayvan ID'.padRight(9)} | ${'Aşı Türü'.padRight(20)} | ${'Tarih'.padRight(25)} | ${'Doz'.padRight(10)} |');
    print('-'.padRight(85, '-'));

    for (var record in records) {
      print(
          '| ${record['id'].toString().padRight(4)} | ${record['hayvan_id'].toString().padRight(9)} | ${(record['asi_turu'] ?? '').toString().padRight(20)} | ${(record['asi_tarihi'] ?? '').toString().padRight(25)} | ${(record['doz'] ?? '').toString().padRight(10)} |');
    }

    print('-'.padRight(85, '-'));
  } catch (e) {
    print('Aşı kayıtları alınırken bir hata oluştu: $e');
  }
}

// Aşı Kaydı Ekleme
Future<void> addVaccineRecord(SupabaseAdapter adapter) async {
  print('\n--- Yeni Aşı Kaydı Ekle ---');

  // Önce hayvanları listeleyelim
  try {
    final hayvanlar = await adapter.getHayvanlar();
    if (hayvanlar.isEmpty) {
      print('Kayıtlı hayvan bulunamadı. Önce hayvan eklemelisiniz.');
      return;
    }

    print('\nHayvan Listesi:');
    for (var hayvan in hayvanlar) {
      print(
          'ID: ${hayvan['id']}, Küpe No: ${hayvan['kupe_no']}, Tür: ${hayvan['tur']}');
    }

    stdout.write('\nHayvan ID: ');
    final hayvanId = stdin.readLineSync() ?? '';

    stdout.write('Aşı Türü: ');
    final asiTuru = stdin.readLineSync() ?? '';

    stdout.write('Doz: ');
    final doz = stdin.readLineSync() ?? '';

    final asiData = {
      'hayvan_id': hayvanId,
      'asi_tarihi': DateTime.now().toIso8601String(),
      'asi_turu': asiTuru,
      'doz': doz,
    };

    print('\nAşı kaydı ekleniyor...');
    final result = await adapter.addAsiKaydi(asiData);

    if (result != null) {
      print('\nAşı kaydı başarıyla eklendi!');
      print('ID: ${result['id']}');
      print('Hayvan ID: ${result['hayvan_id']}');
      print('Aşı Türü: ${result['asi_turu']}');
      print('Tarih: ${result['asi_tarihi']}');
      print('Doz: ${result['doz']}');
    } else {
      print('Aşı kaydı eklenemedi.');
    }
  } catch (e) {
    print('Aşı kaydı eklenirken bir hata oluştu: $e');
  }
}
