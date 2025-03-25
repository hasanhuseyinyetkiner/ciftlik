import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle
  await dotenv.load();

  // Supabase'i başlat
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const TestSupabaseApp());
}

class TestSupabaseApp extends StatelessWidget {
  const TestSupabaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Bağlantı Testi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final supabase = Supabase.instance.client;
  String connectionStatus = 'Bağlantı kontrol ediliyor...';
  String schemaStatus = 'Schema kontrol ediliyor...';
  List<String> tablesList = [];
  Map<String, dynamic> testData = {};
  bool isConnected = false;
  bool hasSchema = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      // Basit bir ping testi
      final response =
          await supabase.from('hayvanlar').select('count').limit(1);

      setState(() {
        isConnected = true;
        connectionStatus = 'Bağlantı başarılı ✓';
      });

      // Schema durumunu kontrol et
      await checkSchema();

      // Tablolar listesini al
      await listTables();

      // Test verisi al
      await fetchTestData();
    } catch (e) {
      setState(() {
        connectionStatus = 'Bağlantı hatası: ${e.toString()}';
      });
    }
  }

  Future<void> checkSchema() async {
    try {
      // Supabase'de RPC function çağrısı ile schema durumunu kontrol et
      final response = await supabase.rpc('list_tables');

      setState(() {
        hasSchema = response != null && response.isNotEmpty;
        schemaStatus = hasSchema
            ? 'Schema uygulandı ✓ (${response.length} tablo bulundu)'
            : 'Schema uygulanmadı ✗';
      });
    } catch (e) {
      setState(() {
        schemaStatus = 'Schema kontrolünde hata: ${e.toString()}';
      });
    }
  }

  Future<void> listTables() async {
    try {
      // Tabloları listele
      final response = await supabase.rpc('list_tables');

      if (response != null) {
        final tables = List<String>.from(response);
        setState(() {
          tablesList = tables;
        });

        // Tablo varlığını kontrol et
        for (final table in tablesList) {
          try {
            final result = await supabase.from(table).select();
            print(
                'Tablo $table: ${result != null ? 'erişilebilir' : 'erişilemiyor'}');
          } catch (e) {
            print('Tablo $table hatası: $e');
          }
        }
      }
    } catch (e) {
      print('Tablo listesini alma hatası: $e');
    }
  }

  Future<void> fetchTestData() async {
    try {
      // Hayvanlar tablosundan test verisi al
      if (tablesList.contains('hayvanlar')) {
        final response = await supabase
            .from('hayvanlar')
            .select()
            .order('id', ascending: false);

        setState(() {
          testData = {
            'hayvanlar': response,
          };
        });
      }
    } catch (e) {
      print('Test verisi alma hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Bağlantı Testi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle : Icons.error,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bağlantı Durumu',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(connectionStatus),
                    const SizedBox(height: 16),
                    Text('Supabase URL: ${dotenv.env['SUPABASE_URL']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasSchema ? Icons.check_circle : Icons.error,
                          color: hasSchema ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Schema Durumu',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(schemaStatus),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (tablesList.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tablolar',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...tablesList
                          .map((table) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text('• $table'),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (testData.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Verisi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final entry in testData.entries)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ${entry.value is List ? '${entry.value.length} kayıt' : entry.value}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (entry.value is List && entry.value.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, top: 8),
                                child: Text(
                                  'İlk kayıt: ${entry.value.first}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            connectionStatus = 'Bağlantı kontrol ediliyor...';
            schemaStatus = 'Schema kontrol ediliyor...';
            tablesList = [];
            testData = {};
            isConnected = false;
            hasSchema = false;
          });
          checkConnection();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
