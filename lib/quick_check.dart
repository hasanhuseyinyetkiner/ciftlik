import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Dosyadan Supabase URL ve API Key'i oku
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('HATA: .env dosyası bulunamadı');
    exit(1);
  }

  final envLines = await envFile.readAsLines();
  String? supabaseUrl;
  String? supabaseKey;

  for (final line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) {
      supabaseUrl = line.substring('SUPABASE_URL='.length).trim();
    } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
      supabaseKey = line.substring('SUPABASE_ANON_KEY='.length).trim();
    }
  }

  if (supabaseUrl == null || supabaseKey == null) {
    print('HATA: Supabase URL veya API Key bulunamadı');
    exit(1);
  }

  print('\nSupabase bağlantı bilgileri doğrulandı:');
  print('URL: $supabaseUrl');
  print('API Key: ${supabaseKey.substring(0, 15)}...\n');

  // Mevcut tabloları kontrol et
  print('=== Mevcut Tablolar ===');
  await checkTable(supabaseUrl, supabaseKey, 'hayvanlar');
  await checkTable(supabaseUrl, supabaseKey, 'hayvan_not');
  await checkTable(supabaseUrl, supabaseKey, 'saglik_kayitlari');
  await checkTable(supabaseUrl, supabaseKey, 'asi_kayitlari');
  await checkTable(supabaseUrl, supabaseKey, 'sut_uretim');
  await checkTable(supabaseUrl, supabaseKey, 'yem_tuketim');

  // Mevcut tespit edilen tablolar
  await checkTable(supabaseUrl, supabaseKey, 'sayim');
  await checkTable(supabaseUrl, supabaseKey, 'hayvan');
  await checkTable(supabaseUrl, supabaseKey, 'suru');
  await checkTable(supabaseUrl, supabaseKey, 'asilama');
  await checkTable(supabaseUrl, supabaseKey, 'sut_miktari');

  // Mevcut fonksiyonları kontrol et
  print('\n=== Mevcut Fonksiyonlar ===');
  await checkFunction(supabaseUrl, supabaseKey, 'ping');
  await checkFunction(supabaseUrl, supabaseKey, 'list_tables');
  await checkFunction(supabaseUrl, supabaseKey, 'get_all_tables');
  await checkFunction(supabaseUrl, supabaseKey, 'exec_sql');
  
  // Uygulamanın veri ekleyememesini anlama testi
  print('\n=== Uygulama Test Senaryosu ===');
  await testHayvanEkleme(supabaseUrl, supabaseKey);
  
  // Mevcut şema yapısını getir
  print('\n=== Veritabanı Şema Yapısı ===');
  await getSchemaInfo(supabaseUrl, supabaseKey);

  print('\nKontrol tamamlandı.');
}

Future<void> checkTable(String baseUrl, String apiKey, String tableName) async {
  final response = await http.get(
    Uri.parse('$baseUrl/rest/v1/$tableName?select=*&limit=1'),
    headers: {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
    },
  );

  if (response.statusCode == 200) {
    print('✅ $tableName tablosu mevcut');
  } else {
    print(
        '❌ $tableName tablosu bulunamadı (${response.statusCode}): ${response.body}');
  }
}

Future<void> checkFunction(
    String baseUrl, String apiKey, String functionName) async {
  final response = await http.post(
    Uri.parse('$baseUrl/rest/v1/rpc/$functionName'),
    headers: {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: '{}',
  );

  if (response.statusCode == 200) {
    print('✅ $functionName fonksiyonu mevcut. Cevap: ${response.body}');
  } else {
    print(
        '❌ $functionName fonksiyonu bulunamadı (${response.statusCode}): ${response.body}');
  }
}

// Hayvan ekleme işlemi test fonksiyonu
Future<void> testHayvanEkleme(String baseUrl, String apiKey) async {
  // Önce hayvan tablosunu test edelim (mevcut olan)
  try {
    final hayvanData = {
      'isim': 'Test Hayvan',
      'kupeno': 'TEST${DateTime.now().millisecondsSinceEpoch}',
      'cinsiyet': 'Dişi',
      'dogum_tarihi': DateTime.now().toIso8601String()
    };
    
    final hayvanResponse = await http.post(
      Uri.parse('$baseUrl/rest/v1/hayvan'),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: jsonEncode(hayvanData),
    );
    
    print('Hayvan tablosuna ekleme denemesi: ${hayvanResponse.statusCode}');
    print('Yanıt: ${hayvanResponse.body}');
    
    if (hayvanResponse.statusCode >= 200 && hayvanResponse.statusCode < 300) {
      print('✅ Hayvan verisi başarıyla eklendi! Uygulamada bu tabloya veri eklenebilmeli.');
    } else {
      print('❌ Hayvan verisi eklenemedi, bu nedenle uygulama veri ekleyemiyor olabilir.');
    }
    
    // Şimdi hayvanlar tablosunu test edelim (olmayan tablo)
    final hayvanlarData = {
      'kupe_no': 'TEST${DateTime.now().millisecondsSinceEpoch}',
      'tur': 'Sığır',
      'cinsiyet': 'Dişi',
      'dogum_tarihi': DateTime.now().toIso8601String()
    };
    
    final hayvanlarResponse = await http.post(
      Uri.parse('$baseUrl/rest/v1/hayvanlar'),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: jsonEncode(hayvanlarData),
    );
    
    print('\nHayvanlar tablosuna ekleme denemesi: ${hayvanlarResponse.statusCode}');
    print('Yanıt: ${hayvanlarResponse.body}');
    
    if (hayvanlarResponse.statusCode == 404) {
      print('❌ Hayvanlar tablosu olmadığı için veri eklenemiyor. Uygulama bu tabloyu kullanıyor olabilir.');
    }
  } catch (e) {
    print('❌ Test sırasında hata oluştu: $e');
  }
}

// Veritabanının mevcut şemasını alır
Future<void> getSchemaInfo(String baseUrl, String apiKey) async {
  try {
    // Doğrudan execute SQL fonksiyonu olmadığından, public tablolarını almaya çalış
    final response = await http.get(
      Uri.parse('$baseUrl/rest/v1/'),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );
    
    print('Şema bilgisi yanıtı (${response.statusCode}): ${response.body}');
    
    // Mevcut tabloların yapısını kontrol et
    if (await tableExists(baseUrl, apiKey, 'hayvan')) {
      await getTableStructure(baseUrl, apiKey, 'hayvan');
    }
  } catch (e) {
    print('❌ Şema bilgisi alınırken hata oluştu: $e');
  }
}

Future<bool> tableExists(String baseUrl, String apiKey, String tableName) async {
  final response = await http.get(
    Uri.parse('$baseUrl/rest/v1/$tableName?select=*&limit=1'),
    headers: {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
    },
  );
  
  return response.statusCode == 200;
}

Future<void> getTableStructure(String baseUrl, String apiKey, String tableName) async {
  try {
    // Tablo sütunlarını görmek için bir kayıt alalım
    final response = await http.get(
      Uri.parse('$baseUrl/rest/v1/$tableName?select=*&limit=1'),
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );
    
    if (response.statusCode == 200 && response.body.isNotEmpty && response.body != '[]') {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        print('\n$tableName tablosu sütunları:');
        final columns = data[0].keys.toList();
        for (var column in columns) {
          print('  - $column: ${getValueType(data[0][column])}');
        }
      } else {
        print('\n$tableName tablosu boş veya veri yok');
      }
    } else {
      print('\n$tableName tablosunun yapısı alınamadı: ${response.statusCode}');
    }
  } catch (e) {
    print('\n$tableName tablosunun yapısı alınırken hata oluştu: $e');
  }
}

String getValueType(dynamic value) {
  if (value == null) return 'null';
  return value.runtimeType.toString();
}
