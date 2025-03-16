import 'package:flutter/material.dart';
import '../../models/tmr_rasyon_model.dart';
import '../../models/tmr_rasyon_detay_model.dart';
import '../../services/yem_service.dart';
import '../../services/database_service.dart';

class TMRRasyonFormScreen extends StatefulWidget {
  final TmrRasyonModel? rasyon;

  const TMRRasyonFormScreen({super.key, this.rasyon});

  @override
  State<TMRRasyonFormScreen> createState() => _TMRRasyonFormScreenState();
}

class _TMRRasyonFormScreenState extends State<TMRRasyonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yemService = YemService(DatabaseService());

  late TextEditingController _rasyonAdiController;
  late TextEditingController _toplamMiktarController;
  List<TmrRasyonDetayModel> _detaylar = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rasyonAdiController = TextEditingController(
      text: widget.rasyon?.rasyonAdi,
    );
    _toplamMiktarController = TextEditingController(
      text: widget.rasyon?.toplamMiktar.toString(),
    );
    if (widget.rasyon != null) {
      _loadRasyonDetaylar();
    }
  }

  @override
  void dispose() {
    _rasyonAdiController.dispose();
    _toplamMiktarController.dispose();
    super.dispose();
  }

  Future<void> _loadRasyonDetaylar() async {
    if (widget.rasyon?.rasyonId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final detaylar = await _yemService.getRasyonDetaylari(
        widget.rasyon!.rasyonId!,
      );
      setState(() {
        _detaylar = detaylar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Rasyon detayları yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRasyon() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final rasyon = TmrRasyonModel(
        rasyonId: widget.rasyon?.rasyonId,
        rasyonAdi: _rasyonAdiController.text,
        toplamMiktar: double.parse(_toplamMiktarController.text),
        olusturmaTarihi: widget.rasyon?.olusturmaTarihi ?? DateTime.now(),
      );

      if (widget.rasyon == null) {
        await _yemService.createRasyon(rasyon);
      } else {
        await _yemService.updateRasyon(rasyon);
      }

      if (_detaylar.isNotEmpty) {
        await _yemService.createRasyonDetay(_detaylar);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = 'Rasyon kaydedilirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rasyon == null ? 'Yeni Rasyon' : 'Rasyon Düzenle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextFormField(
                      controller: _rasyonAdiController,
                      decoration: const InputDecoration(
                        labelText: 'Rasyon Adı',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Rasyon adı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _toplamMiktarController,
                      decoration: const InputDecoration(
                        labelText: 'Toplam Miktar (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Toplam miktar gerekli';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir sayı giriniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveRasyon,
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
