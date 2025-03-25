import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Basit bir Supabase REST API testi
/// Flutter gerektirmeden çalışabilir
void main() async {
  print('\n=== SUPABASE REST API TEST ===\n');

  // Kullanıcıdan URL ve API anahtarını alalım
  String? supabaseUrl;
  String? supabaseKey;

  try {
    // .env dosyasından okumayı deneyelim
    final envFile = File('.env');
    if (await envFile.exists()) {
      final envContent = await envFile.readAsString();
      final lines = envContent.split('\n');

      for (final line in lines) {
        if (line.startsWith('SUPABASE_URL=')) {
          supabaseUrl = line.substring('SUPABASE_URL='.length).trim();
        } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
          supabaseKey = line.substring('SUPABASE_ANON_KEY='.length).trim();
        }
      }
    }
  } catch (e) {
    print('Uyarı: .env dosyası okunamadı: $e');
  }

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    print('Supabase URL giriniz:');
    supabaseUrl = stdin.readLineSync()?.trim();
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      print('Hata: URL gerekli!');
      exit(1);
    }
  }

  if (supabaseKey == null || supabaseKey.isEmpty) {
    print('Supabase Anon Key giriniz:');
    supabaseKey = stdin.readLineSync()?.trim();
    if (supabaseKey == null || supabaseKey.isEmpty) {
      print('Hata: API anahtarı gerekli!');
      exit(1);
    }
  }

  print('URL: $supabaseUrl');
  print('KEY: ${supabaseKey.substring(0, 15)}...\n');

  print('Test menüsü:');
  print('1: Ping testi');
  print('2: Tablo listesi testi');
  print('3: Hayvanlar tablosu testi');
  print('4: SQL çalıştırma testi');
  print('5: Tüm testler');

  print('\nLütfen bir seçenek girin (1-5): ');
  final selection = stdin.readLineSync() ?? '5';

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
    default:
      await testAll(supabaseUrl, supabaseKey);
      break;
  }

  print('\nTestler tamamlandı.');
}

Future<void> testPing(String supabaseUrl, String supabaseKey) async {
  print('\n=== PING TESTİ ===');

  try {
    print('İstek gönderiliyor...');
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
