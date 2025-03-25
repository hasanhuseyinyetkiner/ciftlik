import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_rest_service.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase REST Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SupabaseTestPage(),
    );
  }
}

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({Key? key}) : super(key: key);

  @override
  _SupabaseTestPageState createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final SupabaseRestService _supabaseService = SupabaseRestService();
  bool _isLoading = true;
  bool _isConnected = false;
  String _statusMessage = "Initializing...";
  List<Map<String, dynamic>> _tables = [];
  List<Map<String, dynamic>> _hayvanlar = [];

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Connecting to Supabase...";
    });

    try {
      // Initialize Supabase service
      await _supabaseService.init();

      setState(() {
        _isLoading = false;
        _isConnected = !_supabaseService.isOfflineMode;
        _statusMessage = _isConnected
            ? "Connected to Supabase"
            : "Failed to connect to Supabase";
      });

      if (_isConnected) {
        await _listTables();
        await _listHayvanlar();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isConnected = false;
        _statusMessage = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _listTables() async {
    setState(() {
      _statusMessage = "Fetching tables...";
      _isLoading = true;
    });

    try {
      final result = await _supabaseService.callRpc('list_tables');

      if (result != null) {
        setState(() {
          _tables = List<Map<String, dynamic>>.from(result);
          _statusMessage = "Found ${_tables.length} tables";
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = "Failed to fetch tables";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error fetching tables: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _listHayvanlar() async {
    setState(() {
      _statusMessage = "Fetching hayvanlar...";
      _isLoading = true;
    });

    try {
      final result = await _supabaseService.getData('hayvanlar');

      if (result != null) {
        setState(() {
          _hayvanlar = result;
          _statusMessage = "Found ${_hayvanlar.length} hayvanlar records";
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = "Failed to fetch hayvanlar";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error fetching hayvanlar: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestTable() async {
    setState(() {
      _statusMessage = "Creating test table...";
      _isLoading = true;
    });

    try {
      const createTableSQL = '''
      CREATE TABLE IF NOT EXISTS public.test_table (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        value INTEGER,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      ''';

      final result = await _supabaseService.callRpc('exec_sql', params: {
        'query': createTableSQL,
      });

      if (result != null && result['success'] == true) {
        setState(() {
          _statusMessage = "Test table created successfully";
          _isLoading = false;
        });

        // Refresh tables list
        await _listTables();
      } else {
        setState(() {
          _statusMessage = "Failed to create test table";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error creating test table: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _addTestHayvan() async {
    setState(() {
      _statusMessage = "Adding test hayvan...";
      _isLoading = true;
    });

    try {
      final data = {
        'kupe_no': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        'tur': 'Test Hayvan',
        'irk': 'Test Irk',
        'cinsiyet': 'Erkek',
        'dogum_tarihi': DateTime.now().toIso8601String(),
        'notlar': 'Test hayvan kaydı'
      };

      final result = await _supabaseService.insertData('hayvanlar', data);

      if (result != null) {
        setState(() {
          _statusMessage = "Test hayvan added successfully";
          _isLoading = false;
        });

        // Refresh hayvanlar list
        await _listHayvanlar();
      } else {
        setState(() {
          _statusMessage = "Failed to add test hayvan";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error adding test hayvan: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase REST Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeSupabase,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomAppBar(
        color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _statusMessage,
            style: TextStyle(
              color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _isConnected ? _createTestTable : null,
            label: const Text('Create Test Table'),
            icon: const Icon(Icons.add_box),
            heroTag: 'createTable',
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            onPressed: _isConnected ? _addTestHayvan : null,
            label: const Text('Add Test Hayvan'),
            icon: const Icon(Icons.pets),
            heroTag: 'addHayvan',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    return Padding(
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
                  Text(
                    'Connection Status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.error,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Database Tables',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _tables.isEmpty
                ? const Center(child: Text('No tables found'))
                : ListView.builder(
                    itemCount: _tables.length,
                    itemBuilder: (context, index) {
                      final table = _tables[index];
                      return ListTile(
                        title:
                            Text(table['table_name']?.toString() ?? 'Unknown'),
                        subtitle: Text(
                            'Schema: ${table['table_schema']?.toString() ?? 'Unknown'}'),
                        leading: const Icon(Icons.table_chart),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hayvanlar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _hayvanlar.isEmpty
                ? const Center(child: Text('No hayvanlar found'))
                : ListView.builder(
                    itemCount: _hayvanlar.length,
                    itemBuilder: (context, index) {
                      final hayvan = _hayvanlar[index];
                      return ListTile(
                        title: Text(hayvan['kupe_no']?.toString() ?? 'Unknown'),
                        subtitle: Text('${hayvan['tur']} - ${hayvan['irk']}'),
                        leading: const Icon(Icons.pets),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
