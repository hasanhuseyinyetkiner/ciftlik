import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  bool _isLoading = false;
  String _resultMessage = '';
  List<Map<String, dynamic>> _testData = [];
  final TextEditingController _tableNameController =
      TextEditingController(text: 'hayvanlar');

  @override
  void dispose() {
    _tableNameController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
    });

    try {
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final tableName = _tableNameController.text.trim();

      if (tableName.isEmpty) {
        setState(() {
          _resultMessage = 'Lütfen bir tablo adı girin';
          _isLoading = false;
        });
        return;
      }

      // Supabase'den test verisi çek
      try {
        final response =
            await supabaseService.supabase.from(tableName).select().limit(10);

        setState(() {
          _testData = List<Map<String, dynamic>>.from(response);
          _resultMessage =
              'Bağlantı başarılı! ${_testData.length} kayıt alındı.';
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _resultMessage = 'Veri çekme hatası: $e';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestRecord() async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
    });

    try {
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final tableName = _tableNameController.text.trim();

      if (tableName.isEmpty) {
        setState(() {
          _resultMessage = 'Lütfen bir tablo adı girin';
          _isLoading = false;
        });
        return;
      }

      // Test verisi oluştur
      final testData = {
        'kimlik_no': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        'tur': 'Test Hayvan',
        'alt_tur': 'Test Alt Tür',
        'cinsiyet': 'Belirsiz',
        'dogum_tarihi': DateTime.now().toIso8601String(),
        'durum': 'test',
        'geldiği_yer': 'Test Kaydı',
        'gelis_tarihi': DateTime.now().toIso8601String(),
        'aciklama': 'Bu bir test kaydıdır. Tarih: ${DateTime.now()}',
      };

      // Veritabanına test kaydı ekle
      final response = await supabaseService.insertData(tableName, testData);

      if (response != null) {
        setState(() {
          _resultMessage = 'Test kaydı başarıyla eklendi!';
          _isLoading = false;
        });
        // Listeyi yenile
        _testConnection();
      } else {
        setState(() {
          _resultMessage = 'Kayıt eklenirken bir hata oluştu';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'İşlem hatası: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Test Ekranı'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supabase Bağlantı Testi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tableNameController,
              decoration: const InputDecoration(
                labelText: 'Tablo Adı',
                hintText: 'Örn: hayvanlar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child: const Text('Bağlantıyı Test Et'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createTestRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Kaydı Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _resultMessage.contains('başarı')
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_resultMessage),
              ),
            const SizedBox(height: 16),
            Text(
              'Veriler (${_testData.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _testData.isEmpty
                  ? const Center(child: Text('Veri yok'))
                  : ListView.builder(
                      itemCount: _testData.length,
                      itemBuilder: (context, index) {
                        final item = _testData[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                                item['tur'] ?? item['kimlik_no'] ?? 'İsimsiz'),
                            subtitle: Text(item['aciklama'] ?? 'Açıklama yok'),
                            trailing: Text(item['durum'] ?? '-'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
