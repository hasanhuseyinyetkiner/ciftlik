import 'package:flutter/material.dart';
import '../../models/yem_model.dart' hide YemIslemModel;
import '../../models/yem_islem_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';

class YemIslemFormScreen extends StatefulWidget {
  final YemIslemModel? islem;

  const YemIslemFormScreen({super.key, this.islem});

  @override
  State<YemIslemFormScreen> createState() => _YemIslemFormScreenState();
}

class _YemIslemFormScreenState extends State<YemIslemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yemService = YemService(DatabaseService());

  final _miktarController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _ilgiliSuruIdController = TextEditingController();
  final _islemTipiController = TextEditingController();
  final _birimController = TextEditingController();
  final _birimFiyatController = TextEditingController();

  List<YemModel> _yemler = [];
  YemModel? _selectedYem;
  String? _selectedIslemTipi;
  DateTime _tarih = DateTime.now();
  bool _isLoading = false;

  final _islemTipleri = ['Giriş', 'Çıkış', 'Transfer'];

  @override
  void initState() {
    super.initState();
    _loadYemler();
    if (widget.islem != null) {
      _selectedYem = _yemler.firstWhere((y) => y.yemId == widget.islem!.yemId);
      _miktarController.text = widget.islem!.miktar.toString();
      _islemTipiController.text = widget.islem!.islemTipi;
      _birimController.text = widget.islem!.birim ?? '';
      _birimFiyatController.text = widget.islem!.birimFiyat?.toString() ?? '';
      _tarih = widget.islem!.islemTarihi;
      _aciklamaController.text = widget.islem!.aciklama ?? '';
    }
  }

  @override
  void dispose() {
    _miktarController.dispose();
    _aciklamaController.dispose();
    _ilgiliSuruIdController.dispose();
    _islemTipiController.dispose();
    _birimController.dispose();
    _birimFiyatController.dispose();
    super.dispose();
  }

  Future<void> _loadYemler() async {
    try {
      final yemler = await _yemService.getAllYemler();
      setState(() {
        _yemler = yemler;
        if (widget.islem != null) {
          _selectedYem = _yemler.firstWhere(
            (y) => y.yemId == widget.islem!.yemId,
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
      initialDate: _tarih,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _tarih = picked);
    }
  }

  Future<void> _saveIslem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir yem seçin')));
      return;
    }
    if (_selectedIslemTipi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir işlem tipi seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final islem = YemIslemModel(
        islemId: widget.islem?.islemId,
        yemId: _selectedYem!.yemId!,
        islemTipi: _islemTipiController.text,
        miktar: double.parse(_miktarController.text),
        birim: _birimController.text,
        birimFiyat: _birimFiyatController.text.isNotEmpty
            ? double.parse(_birimFiyatController.text)
            : null,
        islemTarihi: _tarih,
        aciklama: _aciklamaController.text,
      );

      if (widget.islem == null) {
        await _yemService.createIslem(islem);
      } else {
        await _yemService.updateIslem(islem);
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
        title: Text(widget.islem == null ? 'Yeni İşlem' : 'İşlem Düzenle'),
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
            DropdownButtonFormField<String>(
              value: _selectedIslemTipi,
              decoration: const InputDecoration(
                labelText: 'İşlem Tipi',
                border: OutlineInputBorder(),
              ),
              items: _islemTipleri.map((tip) {
                return DropdownMenuItem(value: tip, child: Text(tip));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedIslemTipi = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen bir işlem tipi seçin';
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
              controller: _birimController,
              decoration: const InputDecoration(
                labelText: 'Birim',
                border: OutlineInputBorder(),
              ),
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
            ListTile(
              title: const Text('İşlem Tarihi'),
              subtitle: Text('${_tarih.day}/${_tarih.month}/${_tarih.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ilgiliSuruIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'İlgili Sürü ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (int.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aciklamaController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveIslem,
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
