import 'package:flutter/material.dart';
import '../../models/yem_model.dart' hide YemStokModel;
import '../../models/yem_stok_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';

class YemStokFormScreen extends StatefulWidget {
  final YemStokModel? stok;

  const YemStokFormScreen({super.key, this.stok});

  @override
  State<YemStokFormScreen> createState() => _YemStokFormScreenState();
}

class _YemStokFormScreenState extends State<YemStokFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yemService = YemService(DatabaseService());

  final _miktarController = TextEditingController();
  final _birimFiyatController = TextEditingController();
  final _depoYeriController = TextEditingController();

  List<YemModel> _yemler = [];
  YemModel? _selectedYem;
  DateTime? _sonKullanmaTarihi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadYemler();
    if (widget.stok != null) {
      _miktarController.text = widget.stok!.miktar.toString();
      _birimFiyatController.text = widget.stok!.birimFiyat?.toString() ?? '';
      _depoYeriController.text = widget.stok!.depoYeri ?? '';
      _sonKullanmaTarihi = widget.stok!.sonKullanmaTarihi;
    }
  }

  @override
  void dispose() {
    _miktarController.dispose();
    _birimFiyatController.dispose();
    _depoYeriController.dispose();
    super.dispose();
  }

  Future<void> _loadYemler() async {
    try {
      final yemler = await _yemService.getAllYemler();
      setState(() {
        _yemler = yemler;
        if (widget.stok != null) {
          _selectedYem = _yemler.firstWhere(
            (y) => y.yemId == widget.stok!.yemId,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yemler yüklenirken hata: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sonKullanmaTarihi ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _sonKullanmaTarihi = picked);
    }
  }

  Future<void> _saveStok() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir yem seçin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stok = YemStokModel(
        stokId: widget.stok?.stokId,
        yemId: _selectedYem!.yemId!,
        miktar: double.parse(_miktarController.text),
        birimFiyat: _birimFiyatController.text.isNotEmpty
            ? double.parse(_birimFiyatController.text)
            : null,
        depoYeri: _depoYeriController.text,
        sonKullanmaTarihi: _sonKullanmaTarihi,
      );

      if (widget.stok == null) {
        await _yemService.createStok(stok);
      } else {
        await _yemService.updateStok(stok);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stok == null ? 'Yeni Stok' : 'Stok Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<YemModel>(
              value: _selectedYem,
              decoration: const InputDecoration(
                labelText: 'Yem',
                border: OutlineInputBorder(),
              ),
              items: _yemler.map((yem) {
                return DropdownMenuItem(
                  value: yem,
                  child: Text(yem.yemAdi ?? 'İsimsiz Yem'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedYem = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen bir yem seçin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _miktarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Miktar',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen miktar girin';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birimFiyatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Birim Fiyat',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _depoYeriController,
              decoration: const InputDecoration(
                labelText: 'Depo Yeri',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Son Kullanma Tarihi'),
              subtitle: Text(
                _sonKullanmaTarihi != null
                    ? '${_sonKullanmaTarihi!.day}/${_sonKullanmaTarihi!.month}/${_sonKullanmaTarihi!.year}'
                    : 'Seçilmedi',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveStok,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
