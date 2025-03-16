import 'package:flutter/material.dart';
import '../../models/yem_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';
import 'yem_form_screen.dart';

class YemListScreen extends StatefulWidget {
  const YemListScreen({super.key});

  @override
  State<YemListScreen> createState() => _YemListScreenState();
}

class _YemListScreenState extends State<YemListScreen> {
  final YemService _yemService = YemService(DatabaseService());
  List<YemModel> _yemler = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadYemler();
  }

  Future<void> _loadYemler() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final yemler = await _yemService.getAllYemler();
      setState(() {
        _yemler = yemler;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Yemler yüklenirken hata oluştu: $e';
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
      appBar: AppBar(title: const Text('Yemler')),
      body: _yemler.isEmpty
          ? const Center(child: Text('Henüz yem eklenmemiş'))
          : ListView.builder(
              itemCount: _yemler.length,
              itemBuilder: (context, index) {
                final yem = _yemler[index];
                return ListTile(
                  title: Text(yem.yemAdi ?? 'İsimsiz Yem'),
                  subtitle: Text('Tür: ${yem.tur ?? 'Belirtilmemiş'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await _yemService.deleteYem(yem.yemId!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Yem başarıyla silindi'),
                          ),
                        );
                        await _loadYemler();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Yem silinirken hata: $e')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add yem form screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
