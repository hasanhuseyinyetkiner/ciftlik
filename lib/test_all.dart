import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Supabase REST API testlerinin tümünü otomatik olarak çalıştıran uygulama
void main() async {
  print('\n=== SUPABASE REST API TAM TEST ===\n');

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

  print('Tüm testler başlatılıyor...\n');

  // Tüm testleri sırayla çalıştır
  await testPing(supabaseUrl, supabaseKey);
  await testListTables(supabaseUrl, supabaseKey);
  await testHayvanlarTable(supabaseUrl, supabaseKey);
  await testExecSql(supabaseUrl, supabaseKey);

  print('\nTüm testler tamamlandı.');
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
    } else {
      print('Yanıt: ${response.body}');
    }

    // Başarısız olduysa, get_all_tables fonksiyonunu deneyelim
    print('\nlist_tables çağrısı başarısız. get_all_tables deneniyor...');

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
    } else {
      print('Yanıt: ${response.body}');
    }

    // Alternatif olarak direct veritabanı sorgusu yapalım
    print('\nget_all_tables çağrısı da başarısız. Doğrudan sorgu deneniyor...');

    // Önce exec_sql fonksiyonunu deneyelim
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

    if (response.statusCode == 200) {
      print('exec_sql ile sorgu başarılı!');
      print('Yanıt: ${response.body}');
    } else {
      print('Yanıt: ${response.body}');
      print('Hiçbir yöntem başarılı olmadı.');

      // Son çare olarak doğrudan tablo listesini almayı deneyelim
      print(
          '\nSon çare olarak doğrudan information_schema sorgusu deneniyor...');

      response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/information_schema?select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      ).timeout(const Duration(seconds: 10));

      print('Durum Kodu: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('information_schema sorgusu başarılı!');
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          print('Şemalar: ${data.take(5)}'); // İlk 5 kaydı göster
        } else {
          print('Veri formatı beklenen şekilde değil veya boş');
        }
      } else {
        print('Yanıt: ${response.body}');
      }
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
