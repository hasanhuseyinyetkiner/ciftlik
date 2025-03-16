import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/yem_model.dart' hide YemIslemModel;
import '../../models/yem_islem_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';
import 'yem_islem_form_screen.dart';

class YemIslemListScreen extends StatefulWidget {
  const YemIslemListScreen({super.key});

  @override
  State<YemIslemListScreen> createState() => _YemIslemListScreenState();
}

class _YemIslemListScreenState extends State<YemIslemListScreen> {
  final YemService _yemService = YemService(DatabaseService());
  List<YemIslemModel> _islemler = [];
  bool _isLoading = true;
  String? _error;

  DateTime? _baslangicTarihi;
  DateTime? _bitisTarihi;
  YemModel? _selectedYem;
  List<YemModel> _yemler = [];

  @override
  void initState() {
    super.initState();
    _loadYemler();
    _loadIslemler();
  }

  Future<void> _loadYemler() async {
    try {
      final yemler = await _yemService.getAllYemler();
      setState(() => _yemler = yemler);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yemler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _loadIslemler() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final islemler = await _yemService.getAllIslemler();
      setState(() {
        _islemler = islemler;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'İşlemler yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _baslangicTarihi != null && _bitisTarihi != null
          ? DateTimeRange(start: _baslangicTarihi!, end: _bitisTarihi!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _baslangicTarihi = picked.start;
        _bitisTarihi = picked.end;
      });
      await _loadIslemler();
    }
  }

  void _clearFilters() {
    setState(() {
      _baslangicTarihi = null;
      _bitisTarihi = null;
      _selectedYem = null;
    });
    _loadIslemler();
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
      appBar: AppBar(
        title: const Text('Yem İşlemleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadIslemler),
        ],
      ),
      body: Column(
        children: [
          if (_baslangicTarihi != null ||
              _bitisTarihi != null ||
              _selectedYem != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  const Text('Filtreler: '),
                  if (_baslangicTarihi != null && _bitisTarihi != null)
                    Text(
                      '${DateFormat('dd.MM.yyyy').format(_baslangicTarihi!)} - '
                      '${DateFormat('dd.MM.yyyy').format(_bitisTarihi!)}',
                    ),
                  if (_selectedYem != null) Text(' | ${_selectedYem!.yemAdi}'),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _islemler.isEmpty
                ? const Center(
                    child: Text('Henüz işlem kaydı bulunmamaktadır'),
                  )
                : ListView.builder(
                    itemCount: _islemler.length,
                    itemBuilder: (context, index) {
                      final islem = _islemler[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(islem.yemAdi ?? 'İsimsiz Yem'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İşlem: ${islem.islemTipi}\n'
                                'Miktar: ${islem.miktar} ${islem.birim ?? ''}\n'
                                'Tarih: ${islem.islemTarihi.toLocal().toString().split('.')[0]}',
                              ),
                              Text(
                                'İşlem: ${islem.islemTipi ?? ''} | '
                                'Miktar: ${islem.miktar} ${islem.birim ?? ''}',
                              ),
                              Text(
                                'Tarih: ${DateFormat('dd/MM/yyyy HH:mm').format(islem.islemTarihi)}',
                              ),
                              if (islem.aciklama != null)
                                Text('Not: ${islem.aciklama}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              try {
                                await _yemService.deleteIslem(islem.islemId!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('İşlem başarıyla silindi'),
                                  ),
                                );
                                await _loadIslemler();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'İşlem silinirken hata: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const YemIslemFormScreen()),
          );
          if (created == true) {
            await _loadIslemler();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreleme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tarih Aralığı'),
              subtitle: _baslangicTarihi != null && _bitisTarihi != null
                  ? Text(
                      '${DateFormat('dd.MM.yyyy').format(_baslangicTarihi!)} - '
                      '${DateFormat('dd.MM.yyyy').format(_bitisTarihi!)}',
                    )
                  : const Text('Seçilmedi'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Navigator.pop(context);
                _selectDateRange(context);
              },
            ),
            ListTile(
              title: const Text('Yem'),
              subtitle: Text(_selectedYem?.yemAdi ?? 'Seçilmedi'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () {
                Navigator.pop(context);
                _showYemSelectionDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearFilters();
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _showYemSelectionDialog(BuildContext context) async {
    final selected = await showDialog<YemModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yem Seçimi'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _yemler.length,
            itemBuilder: (context, index) {
              final yem = _yemler[index];
              return ListTile(
                title: Text(yem.yemAdi ?? 'İsimsiz Yem'),
                selected: yem.yemId == _selectedYem?.yemId,
                onTap: () => Navigator.pop(context, yem),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() => _selectedYem = selected);
      await _loadIslemler();
    }
  }
}
