import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hataları yakala
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    developer.log('Flutter Error: ${details.exception}',
        error: details.exception, stackTrace: details.stack);
  };

  // .env dosyasını yükle
  try {
    await dotenv.load();
    developer.log(
        'Env dosyası yüklendi: SUPABASE_URL=${dotenv.env['SUPABASE_URL']?.substring(0, 15)}...');
  } catch (e) {
    developer.log('Env dosyası yüklenirken hata: $e');
  }

  runApp(const SupabaseRestTestApp());
}

class SupabaseRestTestApp extends StatelessWidget {
  const SupabaseRestTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase REST Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Bağlantı bilgileri kontrol ediliyor...';
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        setState(() {
          _status = 'Hata: SUPABASE_URL bulunamadı';
          _error = 'Lütfen .env dosyasını kontrol edin';
        });
        return;
      }

      if (supabaseKey == null || supabaseKey.isEmpty) {
        setState(() {
          _status = 'Hata: SUPABASE_ANON_KEY bulunamadı';
          _error = 'Lütfen .env dosyasını kontrol edin';
        });
        return;
      }

      setState(() {
        _status = 'Supabase bağlantısı kontrol ediliyor...';
      });

      // Ping ile bağlantıyı test et
      try {
        final response = await http.post(
          Uri.parse('$supabaseUrl/rest/v1/rpc/ping'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 && response.body.contains('pong')) {
          setState(() {
            _status = 'Bağlantı başarılı!';
            _isReady = true;
          });
        } else {
          setState(() {
            _status = 'Ping başarısız';
            _error =
                'Durum Kodu: ${response.statusCode}, Yanıt: ${response.body}';
          });
        }
      } catch (e) {
        setState(() {
          _status = 'Bağlantı hatası';
          _error = 'Ping fonksiyonu çağrılırken hata: $e';
        });
        developer.log('Ping hatası', error: e);
      }
    } catch (e) {
      setState(() {
        _status = 'Genel hata';
        _error = e.toString();
      });
      developer.log('Genel hata', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Supabase REST API Test',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'URL: ${dotenv.env['SUPABASE_URL'] ?? 'Bulunamadı'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            if (_isReady)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SupabaseRestTestPage(),
                    ),
                  );
                },
                child: const Text('Test Uygulamasını Başlat'),
              )
            else
              ElevatedButton(
                onPressed: _checkConnection,
                child: const Text('Tekrar Dene'),
              ),
          ],
        ),
      ),
    );
  }
}

class SupabaseRestTestPage extends StatefulWidget {
  const SupabaseRestTestPage({Key? key}) : super(key: key);

  @override
  State<SupabaseRestTestPage> createState() => _SupabaseRestTestPageState();
}

class _SupabaseRestTestPageState extends State<SupabaseRestTestPage> {
  final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final String supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase REST API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Durum bilgisi
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supabase URL: ${supabaseUrl.substring(0, 20)}...',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Test butonları
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testPing,
                  child: const Text('Test Ping'),
                ),
                ElevatedButton(
                  onPressed: _testListTables,
                  child: const Text('Test Tablo Listesi'),
                ),
                ElevatedButton(
                  onPressed: _testHayvanlarTable,
                  child: const Text('Test Hayvanlar Tablosu'),
                ),
                ElevatedButton(
                  onPressed: _testExecSql,
                  child: const Text('Test SQL Çalıştırma'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sonuçlar alanı
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(_testResults),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ping RPC fonksiyonunu test et
  Future<void> _testPing() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Ping fonksiyonu çağrılıyor...\n';
    });

    try {
      developer.log('Ping isteği gönderiliyor: $supabaseUrl/rest/v1/rpc/ping');

      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/ping'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      developer.log('Ping yanıtı: ${response.statusCode} - ${response.body}');

      setState(() {
        _testResults += 'Durum Kodu: ${response.statusCode}\n';
        _testResults += 'Yanıt: ${response.body}\n';

        if (response.statusCode == 200 && response.body.contains('pong')) {
          _testResults += '\nBaşarılı: Ping fonksiyonu çalışıyor!';
        } else {
          _testResults += '\nHata: Ping fonksiyonu çalışmıyor.';
          _testResults += '\nHata detayı: ${response.body}';
        }
      });
    } catch (e) {
      developer.log('Ping hatası', error: e);
      setState(() {
        _testResults += '\nHata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tablo listesini getiren RPC fonksiyonunu test et
  Future<void> _testListTables() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Tablo listesi alınıyor...\n';
    });

    try {
      // İlk olarak list_tables fonksiyonunu deneyelim
      developer.log('list_tables isteği gönderiliyor');
      var response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/list_tables'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      developer.log('list_tables yanıtı: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _testResults += 'list_tables çağrısı başarılı!\n';
          _testResults += 'Tablolar: ${response.body}\n';
        });
      } else {
        // Başarısız olduysa, get_all_tables fonksiyonunu deneyelim
        _testResults +=
            'list_tables çağrısı başarısız. get_all_tables deneniyor...\n';

        developer.log('get_all_tables isteği gönderiliyor');
        response = await http.post(
          Uri.parse('$supabaseUrl/rest/v1/rpc/get_all_tables'),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        developer.log('get_all_tables yanıtı: ${response.statusCode}');

        if (response.statusCode == 200) {
          setState(() {
            _testResults += 'get_all_tables çağrısı başarılı!\n';
            _testResults += 'Tablolar: ${response.body}\n';
          });
        } else {
          // Alternatif olarak direct veritabanı sorgusu yapalım
          _testResults +=
              'get_all_tables çağrısı da başarısız. Doğrudan sorgu deneniyor...\n';

          developer.log('exec_sql ile tablolar sorgusu yapılıyor');
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

          developer.log('exec_sql yanıtı: ${response.statusCode}');

          setState(() {
            _testResults += 'Durum Kodu: ${response.statusCode}\n';
            _testResults += 'Yanıt: ${response.body}\n';
          });
        }
      }
    } catch (e) {
      developer.log('Tablo listesi hatası', error: e);
      setState(() {
        _testResults += '\nHata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hayvanlar tablosundan veri çekmeyi test et
  Future<void> _testHayvanlarTable() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Hayvanlar tablosundan veri alınıyor...\n';
    });

    try {
      developer.log('Hayvanlar tablosu sorgulanıyor');
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/hayvanlar?select=*'),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      ).timeout(const Duration(seconds: 10));

      developer.log('Hayvanlar yanıtı: ${response.statusCode}');

      setState(() {
        _testResults += 'Durum Kodu: ${response.statusCode}\n';

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _testResults += 'Hayvan Sayısı: ${data.length}\n';
          _testResults +=
              'İlk kayıt: ${data.isNotEmpty ? jsonEncode(data.first) : "Veri yok"}\n';
          _testResults += '\nBaşarılı: ${data.length} hayvan kaydı bulundu.';
        } else {
          _testResults += 'Yanıt: ${response.body}\n';
          _testResults += '\nHata: Hayvanlar tablosuna erişilemedi.';
        }
      });
    } catch (e) {
      developer.log('Hayvanlar tablosu hatası', error: e);
      setState(() {
        _testResults += '\nHata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // exec_sql fonksiyonunu test et
  Future<void> _testExecSql() async {
    setState(() {
      _isLoading = true;
      _testResults = 'SQL sorgusu çalıştırılıyor...\n';
    });

    try {
      developer.log('exec_sql isteği gönderiliyor');
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

      developer.log('exec_sql yanıtı: ${response.statusCode}');

      setState(() {
        _testResults += 'Durum Kodu: ${response.statusCode}\n';
        _testResults += 'Yanıt: ${response.body}\n';

        if (response.statusCode == 200) {
          _testResults += '\nBaşarılı: SQL sorgusu çalıştırıldı!';
        } else {
          _testResults += '\nHata: SQL sorgusu çalıştırılamadı.';
        }
      });
    } catch (e) {
      developer.log('exec_sql hatası', error: e);
      setState(() {
        _testResults += '\nHata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
