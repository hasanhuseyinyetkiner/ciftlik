import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
        'https://wahoyhkhwvetpopnopqa.supabase.co';
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhaG95aGtod3ZldHBvcG5vcHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0NjcwMTksImV4cCI6MjA1ODA0MzAxOX0.fG9eMAdGsFONMVKSIOt8QfkZPRBjrSsoKrxgCbgAbhY';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  runApp(const TestSupabaseApp());
}

class TestSupabaseApp extends StatelessWidget {
  const TestSupabaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Supabase Connection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final DataService _dataService = DataService();
  String _connectionStatus = 'Not tested';
  String _schemaStatus = 'Not verified';
  String _tablesList = 'Not checked';
  List<Map<String, dynamic>> _testData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Checking connection...';
    });

    try {
      await _supabaseService.init();
      final connected = await _supabaseService.checkConnection();

      setState(() {
        _connectionStatus = connected
            ? 'Connected to Supabase successfully'
            : 'Failed to connect to Supabase';
      });

      if (connected) {
        await _checkSchema();
        await _listTables();
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error checking connection: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkSchema() async {
    setState(() {
      _schemaStatus = 'Checking schema...';
    });

    try {
      // Try executing a simple query to check if schema has been applied
      final result = await _supabaseService.executeRawQuery(
        'ping',
        useCache: false,
      );

      setState(() {
        _schemaStatus = result != null
            ? 'Schema appears to be working (ping function responded)'
            : 'Schema might not be properly applied';
      });
    } catch (e) {
      setState(() {
        _schemaStatus = 'Error checking schema: $e';
      });
    }
  }

  Future<void> _listTables() async {
    setState(() {
      _tablesList = 'Fetching tables...';
    });

    try {
      // Use a PostgreSQL system query to list tables
      final result = await _supabaseService.executeRawQuery(
        'list_tables',
        useCache: false,
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          _tablesList =
              'Tables found: ${result.map((r) => r['table_name']).join(', ')}';
        });
      } else {
        // Fallback to check if specific tables exist
        final tables = ['kullanici', 'hayvan', 'suru', 'tohumlama', 'asi'];
        final tablesStatus = <String>[];

        for (final table in tables) {
          try {
            final result = await _supabaseService.getData(table);
            tablesStatus
                .add('$table: ${result != null ? 'exists' : 'not found'}');
          } catch (e) {
            tablesStatus.add('$table: error ($e)');
          }
        }

        setState(() {
          _tablesList = tablesStatus.join('\n');
        });
      }
    } catch (e) {
      setState(() {
        _tablesList = 'Error listing tables: $e';
      });
    }
  }

  Future<void> _testDataFetch() async {
    setState(() {
      _isLoading = true;
      _testData = [];
    });

    try {
      // Try to fetch some test data from the hayvan table
      final result = await _dataService.fetchData(
        apiEndpoint: 'Animals',
        tableName: 'hayvan',
      );

      setState(() {
        _testData = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching test data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Connection Status', _connectionStatus),
                  _buildSection('Schema Status', _schemaStatus),
                  _buildSection('Tables', _tablesList),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _testDataFetch,
                    child: const Text('Test Data Fetch'),
                  ),
                  if (_testData.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Sample Data:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _testData.length,
                        itemBuilder: (context, index) {
                          final item = _testData[index];
                          return ListTile(
                            title: Text(
                                '${item['isim'] ?? 'No Name'} (ID: ${item['hayvan_id'] ?? 'N/A'})'),
                            subtitle: Text(
                                'RFID: ${item['rfid_tag'] ?? 'N/A'}, Küpe: ${item['kupeno'] ?? 'N/A'}'),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkConnection,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(content),
        ),
      ],
    );
  }
}
