import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('HATA: .env dosyası bulunamadı');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final envLines = envContent.split('\n');

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
    print('HATA: SUPABASE_URL veya SUPABASE_ANON_KEY bulunamadı');
    exit(1);
  }

  print('=== SUPABASE BAĞLANTI DURUMU ===');
  print('URL: $supabaseUrl');
  print('KEY: ${supabaseKey.substring(0, 15)}...');

  // 1. Temel REST API bağlantısını kontrol et
  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    print('\n1. REST API Bağlantısı: ${response.statusCode}');
    print('Yanıt: ${response.body}');
  } catch (e) {
    print('\n1. REST API Bağlantı Hatası: $e');
  }

  // 2. Mevcut tabloları kontrol et
  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/hayvanlar?select=*&limit=1'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    print('\n2. Hayvanlar Tablosu Sorgusu: ${response.statusCode}');
    print('Yanıt: ${response.body}');
  } catch (e) {
    print('\n2. Hayvanlar Tablosu Sorgu Hatası: $e');
  }

  // 3. Ping fonksiyonunu kontrol et
  try {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/ping'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    print('\n3. Ping Fonksiyonu: ${response.statusCode}');
    print('Yanıt: ${response.body}');
  } catch (e) {
    print('\n3. Ping Fonksiyonu Hatası: $e');
  }

  // 4. Schema bilgisini almaya çalış
  try {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    );
    print('\n4. Schema Bilgisi: ${response.statusCode}');
    print('Yanıt: ${response.body}');
  } catch (e) {
    print('\n4. Schema Bilgisi Hatası: $e');
  }

  print('\nKontrol tamamlandı.');
}
