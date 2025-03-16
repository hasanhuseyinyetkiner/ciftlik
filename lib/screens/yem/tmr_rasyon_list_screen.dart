import 'package:flutter/material.dart';
import '../../models/tmr_rasyon_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';
import 'tmr_rasyon_form_screen.dart';

class TMRRasyonListScreen extends StatefulWidget {
  const TMRRasyonListScreen({super.key});

  @override
  State<TMRRasyonListScreen> createState() => _TMRRasyonListScreenState();
}

class _TMRRasyonListScreenState extends State<TMRRasyonListScreen> {
  final YemService _yemService = YemService(DatabaseService());
  List<TmrRasyonModel> _rasyonlar = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRasyonlar();
  }

  Future<void> _loadRasyonlar() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final rasyonlar = await _yemService.getAllRasyonlar();
      setState(() {
        _rasyonlar = rasyonlar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Rasyonlar yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRasyon(TmrRasyonModel rasyon) async {
    try {
      await _yemService.deleteRasyon(rasyon.rasyonId!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rasyon başarıyla silindi')));
      await _loadRasyonlar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasyon silinirken hata oluştu: $e')),
      );
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
      appBar: AppBar(title: const Text('TMR Rasyonları')),
      body: _rasyonlar.isEmpty
          ? const Center(child: Text('Henüz rasyon eklenmemiş'))
          : ListView.builder(
              itemCount: _rasyonlar.length,
              itemBuilder: (context, index) {
                final rasyon = _rasyonlar[index];
                return ListTile(
                  title: Text(rasyon.rasyonAdi),
                  subtitle: Text(
                    'Toplam Miktar: ${rasyon.toplamMiktar} kg\n'
                    'Tarih: ${rasyon.olusturmaTarihi.toLocal().toString().split('.')[0]}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteRasyon(rasyon),
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TMRRasyonFormScreen(rasyon: rasyon),
                      ),
                    );
                    if (result == true) {
                      await _loadRasyonlar();
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TMRRasyonFormScreen(),
            ),
          );
          if (result == true) {
            await _loadRasyonlar();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
