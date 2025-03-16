import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'HayvanAsiController.dart';
import 'AsiModeli.dart';
import 'AsiController.dart';

class HayvanAsiEkleSayfasi extends StatefulWidget {
  final String kupeNo;
  final String hayvanAdi;

  const HayvanAsiEkleSayfasi({
    Key? key,
    required this.kupeNo,
    required this.hayvanAdi,
  }) : super(key: key);

  @override
  _HayvanAsiEkleSayfasiState createState() => _HayvanAsiEkleSayfasiState();
}

class _HayvanAsiEkleSayfasiState extends State<HayvanAsiEkleSayfasi> {
  final HayvanAsiController controller = Get.find<HayvanAsiController>();
  final AsiController asiController = Get.put(AsiController());
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedAsi;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd.MM.yyyy').format(_selectedDate);
    asiController.fetchAsilar();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _vaccineNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd.MM.yyyy').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hayvanAdi} - Aşı Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                        'Küpe No: ${widget.kupeNo}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hayvan: ${widget.hayvanAdi}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Aşı Tarihi',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir tarih seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (asiController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Aşı Türü',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedAsi,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Aşı seçin'),
                      ),
                      ...asiController.asilar.map((asi) {
                        return DropdownMenuItem<String>(
                          value: asi.asiAdi,
                          child: Text(asi.asiAdi),
                        );
                      }).toList(),
                      const DropdownMenuItem<String>(
                        value: 'other',
                        child: Text('Diğer (Manuel Giriş)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAsi = value;
                        if (value != 'other') {
                          _vaccineNameController.text = value ?? '';
                        } else {
                          _vaccineNameController.text = '';
                        }
                      });
                    },
                    validator: (value) {
                      if (_selectedAsi == 'other' && _vaccineNameController.text.isEmpty) {
                        return 'Lütfen aşı adını girin';
                      }
                      return null;
                    },
                  );
                }
              }),
              if (_selectedAsi == 'other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vaccineNameController,
                  decoration: const InputDecoration(
                    labelText: 'Aşı Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen aşı adını girin';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveVaccine,
                  child: Obx(() {
                    return controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Aşı Ekle',
                            style: TextStyle(fontSize: 18),
                          );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveVaccine() async {
    if (_formKey.currentState!.validate()) {
      final String asiAdi = _selectedAsi == 'other'
          ? _vaccineNameController.text
          : _selectedAsi ?? '';

      final hayvanAsi = HayvanAsi(
        kupeNo: widget.kupeNo,
        tarih: _dateController.text,
        asiAdi: asiAdi,
        notlar: _notesController.text,
      );

      await controller.addHayvanAsi(hayvanAsi);
      Get.back();
    }
  }
}
