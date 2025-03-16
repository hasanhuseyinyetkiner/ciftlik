import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/yem_model.dart' hide YemStokModel;
import '../../models/yem_stok_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';
import 'yem_stok_form_screen.dart';

class YemStokListScreen extends StatefulWidget {
  const YemStokListScreen({super.key});

  @override
  State<YemStokListScreen> createState() => _YemStokListScreenState();
}

class _YemStokListScreenState extends State<YemStokListScreen> {
  final YemService _yemService = YemService(DatabaseService());
  List<YemStokModel> _stoklar = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStoklar();
  }

  Future<void> _loadStoklar() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stoklar = await _yemService.getAllStoklar();
      setState(() {
        _stoklar = stoklar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Stoklar yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Yem Stokları')),
      body: _stoklar.isEmpty
          ? const Center(child: Text('Henüz stok kaydı bulunmamaktadır'))
          : ListView.builder(
              itemCount: _stoklar.length,
              itemBuilder: (context, index) {
                final stok = _stoklar[index];
                return ListTile(
                  title: Text(stok.yemAdi ?? 'İsimsiz Yem'),
                  subtitle: Text(
                    'Miktar: ${stok.miktar} ${stok.birim ?? ''}\n'
                    'Son Güncelleme: ${stok.guncellemeTarihi.toLocal().toString().split('.')[0]}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await _yemService.deleteStok(stok.stokId!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Stok başarıyla silindi'),
                          ),
                        );
                        await _loadStoklar();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Stok silinirken hata: $e')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add stok form screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
