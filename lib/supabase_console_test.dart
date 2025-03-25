import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("* Dotenv yükleniyor...");
    await dotenv.load();
    print("* Dotenv yüklendi: URL=${dotenv.env['SUPABASE_URL']}");

    print("* Supabase başlatılıyor...");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    print("* Supabase başlatıldı");

    runApp(const SupabaseConsoleTestApp());
  } catch (e) {
    print("!! HATA: $e");
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('HATA: $e'),
          ),
        ),
      ),
    );
  }
}

class SupabaseConsoleTestApp extends StatelessWidget {
  const SupabaseConsoleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Console Test',
      home: SupabaseConsoleTestPage(),
    );
  }
}

class SupabaseConsoleTestPage extends StatefulWidget {
  @override
  _SupabaseConsoleTestPageState createState() =>
      _SupabaseConsoleTestPageState();
}

class _SupabaseConsoleTestPageState extends State<SupabaseConsoleTestPage> {
  final supabase = Supabase.instance.client;
  String message = "Hazır";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supabase Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testRPC,
              child: Text('RPC Test (list_tables)'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testAltRPC,
              child: Text('RPC Test (get_all_tables)'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testHayvanlar,
              child: Text('Hayvanlar Tablosunu Test Et'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testDirectSQL,
              child: Text('Doğrudan SQL Sorgusu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testRPC() async {
    print("* RPC testi başlatılıyor (list_tables)...");
    try {
      print("* list_tables fonksiyonu çağrılıyor...");
      final result = await supabase.rpc('list_tables');

      print("* RPC sonucu: $result");
      setState(() {
        message =
            "RPC testi başarılı: ${result != null ? result.length : 0} tablo bulundu";
      });
    } catch (e) {
      print("!! RPC Hatası: $e");
      setState(() {
        message = "RPC Hatası: $e";
      });
    }
  }

  Future<void> _testAltRPC() async {
    print("* RPC testi başlatılıyor (get_all_tables)...");
    try {
      print("* get_all_tables fonksiyonu çağrılıyor...");
      final result = await supabase.rpc('get_all_tables');

      print("* RPC sonucu: $result");
      setState(() {
        message =
            "RPC testi başarılı (get_all_tables): ${result != null ? result.length : 0} tablo bulundu";
      });
    } catch (e) {
      print("!! RPC Hatası (get_all_tables): $e");
      setState(() {
        message = "RPC Hatası (get_all_tables): $e";
      });
    }
  }

  Future<void> _testHayvanlar() async {
    print("* Hayvanlar tablosu testi başlatılıyor...");
    try {
      print("* hayvanlar tablosundan veri çekiliyor...");
      final result = await supabase.from('hayvanlar').select();

      print("* Tablo sonucu: ${result?.length ?? 0} kayıt bulundu");
      print(
          "* İlk kayıt: ${result?.isNotEmpty == true ? result?.first : 'Kayıt yok'}");

      setState(() {
        message =
            "Hayvanlar tablosu testi başarılı: ${result?.length ?? 0} kayıt bulundu";
      });
    } catch (e) {
      print("!! Hayvanlar Tablosu Hatası: $e");
      setState(() {
        message = "Hayvanlar Tablosu Hatası: $e";
      });
    }
  }

  Future<void> _testDirectSQL() async {
    print("* Doğrudan SQL sorgusu testi başlatılıyor...");
    try {
      // Tablo listesini doğrudan almak için bir sorgu yapalım
      print("* Tablolar listesi doğrudan alınıyor...");

      final result =
          await supabase.from('_postgrest_metadata').select().limit(1);

      print("* Doğrudan sorgu sonucu: $result");
      setState(() {
        message = "Doğrudan sorgu başarılı: $result";
      });
    } catch (e) {
      print("!! Doğrudan SQL Sorgusu Hatası: $e");
      setState(() {
        message = "Doğrudan SQL Sorgusu Hatası: $e";
      });

      // Farklı bir tablo deneyelim
      try {
        print("* Tables listesi alınıyor...");
        final tables = await supabase
            .from('pg_tables')
            .select()
            .eq('schemaname', 'public');
        print("* PG Tables sonucu: $tables");
        setState(() {
          message = "PG Tables sorgusu: $tables";
        });
      } catch (e2) {
        print("!! PG Tables sorgusu hatası: $e2");
      }
    }
  }
}
