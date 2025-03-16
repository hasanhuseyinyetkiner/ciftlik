import 'package:flutter/material.dart';
import '../../models/yem_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';

class YemFormScreen extends StatefulWidget {
  final YemModel? yem;

  const YemFormScreen({super.key, this.yem});

  @override
  State<YemFormScreen> createState() => _YemFormScreenState();
}

class _YemFormScreenState extends State<YemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yemService = YemService(DatabaseService());

  final _yemAdiController = TextEditingController();
  final _turController = TextEditingController();
  final _birimController = TextEditingController();
  final _aciklamaController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.yem != null) {
      _yemAdiController.text = widget.yem!.yemAdi ?? '';
      _turController.text = widget.yem!.tur ?? '';
      _birimController.text = widget.yem!.birim ?? '';
      _aciklamaController.text = widget.yem!.aciklama ?? '';
    }
  }

  @override
  void dispose() {
    _yemAdiController.dispose();
    _turController.dispose();
    _birimController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _saveYem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final yem = YemModel(
        yemId: widget.yem?.yemId,
        yemAdi: _yemAdiController.text,
        tur: _turController.text,
        birim: _birimController.text,
        aciklama: _aciklamaController.text,
      );

      if (widget.yem == null) {
        await _yemService.createYem(yem);
      } else {
        await _yemService.updateYem(yem);
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
        title: Text(widget.yem == null ? 'Yeni Yem' : 'Yem Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _yemAdiController,
              decoration: const InputDecoration(
                labelText: 'Yem Adı',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen yem adını girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _turController,
              decoration: const InputDecoration(
                labelText: 'Tür',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen yem türünü girin';
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen birimi girin';
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
                onPressed: _isLoading ? null : _saveYem,
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
