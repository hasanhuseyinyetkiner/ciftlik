import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Bu program, Supabase REST API'sini bir komut satırı arayüzü üzerinden
/// test etmek için tasarlanmıştır. UI yerine terminal çıktıları kullanır.
void main() async {
  // .env dosyasını yükle
  print('\n=== SUPABASE REST API TEST CONSOLE ===\n');

  try {
    print('Env dosyası yükleniyor...');
    await dotenv.load();

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    print('SUPABASE_URL: $supabaseUrl');
    print('SUPABASE_ANON_KEY: ${supabaseKey?.substring(0, 15)}...');

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      print('HATA: SUPABASE_URL bulunamadı');
      exit(1);
    }

    if (supabaseKey == null || supabaseKey.isEmpty) {
      print('HATA: SUPABASE_ANON_KEY bulunamadı');
      exit(1);
    }

    print('\n=== TEST MENÜSÜ ===');
    print('1. Ping Testi');
    print('2. Tablo Listesi Testi');
    print('3. Hayvanlar Tablosu Testi');
    print('4. SQL Çalıştırma Testi');
    print('5. Tüm Testleri Çalıştır');
    print('0. Çıkış');

    print('\nBir seçenek girin (0-5): ');
    String? selection = stdin.readLineSync();

    switch (selection) {
      case '1':
        await testPing(supabaseUrl, supabaseKey);
        break;
      case '2':
        await testListTables(supabaseUrl, supabaseKey);
        break;
      case '3':
        await testHayvanlarTable(supabaseUrl, supabaseKey);
        break;
      case '4':
        await testExecSql(supabaseUrl, supabaseKey);
        break;
      case '5':
        await testAll(supabaseUrl, supabaseKey);
        break;
      case '0':
        print('Çıkılıyor...');
        exit(0);
      default:
        print('Geçersiz seçenek. Çıkılıyor...');
        exit(1);
    }
  } catch (e) {
    print('HATA: $e');
    exit(1);
  }

  // Test tamamlandıktan sonra
  print('\nTestler tamamlandı. Çıkmak için Enter tuşuna basın...');
  stdin.readLineSync();
  exit(0);
}

Future<void> testPing(String supabaseUrl, String supabaseKey) async {
  print('\n=== PING TESTİ ===');

  try {
    print('Ping isteği gönderiliyor: $supabaseUrl/rest/v1/rpc/ping');

    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/ping'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Durum Kodu: ${response.statusCode}');
    print('Yanıt: ${response.body}');

    if (response.statusCode == 200 && response.body.contains('pong')) {
      print('BAŞARILI: Ping fonksiyonu çalışıyor!');
    } else {
      print('HATA: Ping fonksiyonu çalışmıyor.');
      print('Hata detayı: ${response.body}');
    }
  } catch (e) {
    print('HATA: $e');
  }
}

Future<void> testListTables(String supabaseUrl, String supabaseKey) async {
  print('\n=== TABLO LİSTESİ TESTİ ===');

  try {
    // İlk olarak list_tables fonksiyonunu deneyelim
    print('list_tables isteği gönderiliyor...');
    var response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/list_tables'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Durum Kodu: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('list_tables çağrısı başarılı!');
      print('Tablolar: ${response.body}');
      return;
    }

    // Başarısız olduysa, get_all_tables fonksiyonunu deneyelim
    print('list_tables çağrısı başarısız. get_all_tables deneniyor...');

    response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/get_all_tables'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Durum Kodu: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('get_all_tables çağrısı başarılı!');
      print('Tablolar: ${response.body}');
      return;
    }

    // Alternatif olarak direct veritabanı sorgusu yapalım
    print('get_all_tables çağrısı da başarısız. Doğrudan sorgu deneniyor...');

    response = await http
        .post(
          Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'query':
                "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'"
          }),
        )
        .timeout(const Duration(seconds: 10));

    print('Durum Kodu: ${response.statusCode}');
    print('Yanıt: ${response.body}');

    if (response.statusCode == 200) {
      print('exec_sql ile sorgu başarılı!');
    } else {
      print('Hiçbir yöntem başarılı olmadı.');
    }
  } catch (e) {
    print('HATA: $e');
  }
}

Future<void> testHayvanlarTable(String supabaseUrl, String supabaseKey) async {
  print('\n=== HAYVANLAR TABLOSU TESTİ ===');

  try {
    print('Hayvanlar tablosu sorgulanıyor...');
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/hayvanlar?select=*'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    ).timeout(const Duration(seconds: 10));

    print('Durum Kodu: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Hayvan Sayısı: ${data.length}');

      if (data.isNotEmpty) {
        print('İlk kayıt:');
        print(const JsonEncoder.withIndent('  ').convert(data[0]));
      } else {
        print('Veri yok');
      }

      print('BAŞARILI: ${data.length} hayvan kaydı bulundu.');
    } else {
      print('Yanıt: ${response.body}');
      print('HATA: Hayvanlar tablosuna erişilemedi.');
    }
  } catch (e) {
    print('HATA: $e');
  }
}

Future<void> testExecSql(String supabaseUrl, String supabaseKey) async {
  print('\n=== SQL ÇALIŞTIRMA TESTİ ===');

  try {
    print('SQL sorgusu çalıştırılıyor...');
    final response = await http
        .post(
          Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
              {'query': "SELECT COUNT(*) as hayvan_sayisi FROM hayvanlar"}),
        )
        .timeout(const Duration(seconds: 10));

    print('Durum Kodu: ${response.statusCode}');
    print('Yanıt: ${response.body}');

    if (response.statusCode == 200) {
      print('BAŞARILI: SQL sorgusu çalıştırıldı!');
    } else {
      print('HATA: SQL sorgusu çalıştırılamadı.');
    }
  } catch (e) {
    print('HATA: $e');
  }
}

Future<void> testAll(String supabaseUrl, String supabaseKey) async {
  await testPing(supabaseUrl, supabaseKey);
  await testListTables(supabaseUrl, supabaseKey);
  await testHayvanlarTable(supabaseUrl, supabaseKey);
  await testExecSql(supabaseUrl, supabaseKey);
}
