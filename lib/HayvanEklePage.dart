import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'SuruYonetimController.dart';
import 'HayvanController.dart'; // Hayvan sınıfını içe aktarıyorum

/*
* HayvanEklePage - Hayvan Ekleme Sayfası
* ----------------------------------
* Bu sayfa, yeni hayvan kaydı oluşturma ve mevcut
* hayvan bilgilerini düzenleme işlevlerini sağlar.
*
* Form Bileşenleri:
* 1. Kimlik Bilgileri:
*    - Küpe numarası
*    - İsim
*    - Tür seçimi
*    - Irk seçimi
*    - Cinsiyet
*    - Doğum tarihi
*
* 2. Fiziksel Özellikler:
*    - Renk
*    - Ağırlık
*    - Boy
*    - Özel işaretler
*    - Fotoğraf ekleme
*
* 3. Soy Bilgileri:
*    - Anne bilgisi
*    - Baba bilgisi
*    - Genetik özellikler
*    - Soy ağacı
*
* 4. Sağlık Bilgileri:
*    - Aşı durumu
*    - Kronik hastalıklar
*    - Alerjiler
*    - Özel durumlar
*
* 5. Grup Bilgileri:
*    - Sürü seçimi
*    - Barınak/Bölme
*    - Beslenme grubu
*    - Özel notlar
*
* Özellikler:
* - Akıllı form validasyonu
* - Otomatik veri doldurma
* - QR/Barkod okuma
* - Çoklu dil desteği
*
* Entegrasyonlar:
* - Veritabanı servisi
* - Dosya yönetimi
* - Bildirim sistemi
* - Sürü yönetimi
*/

class HayvanEklePage extends StatefulWidget {
  const HayvanEklePage({super.key});

  @override
  State<HayvanEklePage> createState() => _HayvanEklePageState();
}

class _HayvanEklePageState extends State<HayvanEklePage> {
  final _formKey = GlobalKey<FormState>();
  final SuruYonetimController _controller = Get.find();

  // Form fields
  int selectedSuruId = 1; // Varsayılan olarak ilk sürü ID'si
  String selectedTur = 'İnek'; // Tür seçimi için varsayılan değer
  final TextEditingController _kupeNoController = TextEditingController();
  String? selectedIrk;
  String? selectedCinsiyet;
  DateTime? selectedDogumTarihi;
  final TextEditingController _chipNoController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _anneKupeNoController = TextEditingController();
  final TextEditingController _babaKupeNoController = TextEditingController();
  final TextEditingController _agirlikController = TextEditingController();
  final TextEditingController _notlarController = TextEditingController();
  bool isDogumTarihiBilinmiyor = false;
  bool isAnneBilinmiyor = false;
  bool isBabaBilinmiyor = false;
  bool isHasta = false;
  bool isGebe = false;
  bool isSatilik = false;

  // Predefined lists
  final List<String> irklar = [
    'Holstein',
    'Simental',
    'Jersey',
    'Montofon',
    'Angus',
    'Hereford',
    'Yerli Kara',
  ];

  @override
  void dispose() {
    _kupeNoController.dispose();
    _chipNoController.dispose();
    _rfidController.dispose();
    _anneKupeNoController.dispose();
    _babaKupeNoController.dispose();
    _agirlikController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hayvan Ekle'),
        actions: [
          TextButton.icon(
            onPressed: _saveHayvan,
            icon: const Icon(Icons.save),
            label: const Text('Kaydet'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Temel Bilgiler'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Sürü Seçimi
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sürü *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedSuruId.toString(),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sürü Seçin'),
                          ),
                          ...(_controller.suruListesi.map((suru) {
                            return DropdownMenuItem(
                              value: suru['id'].toString(),
                              child: Text(suru['ad']),
                            );
                          })).toList(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir sürü seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedSuruId = int.parse(value!);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Küpe No
                      TextFormField(
                        controller: _kupeNoController,
                        decoration: const InputDecoration(
                          labelText: 'Küpe No *',
                          border: OutlineInputBorder(),
                          hintText: 'TR-1234567890',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Küpe no boş olamaz';
                          }
                          if (!value.startsWith('TR-')) {
                            return 'Küpe no TR- ile başlamalıdır';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Irk
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Irk *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedIrk,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Irk Seçin'),
                          ),
                          ...irklar.map((irk) {
                            return DropdownMenuItem(
                              value: irk,
                              child: Text(irk),
                            );
                          }).toList(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir ırk seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedIrk = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cinsiyet
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Cinsiyet *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCinsiyet,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Cinsiyet Seçin'),
                          ),
                          DropdownMenuItem(
                            value: 'E',
                            child: Text('Erkek'),
                          ),
                          DropdownMenuItem(
                            value: 'D',
                            child: Text('Dişi'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen cinsiyet seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedCinsiyet = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Doğum Bilgileri'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Doğum Tarihi
                      CheckboxListTile(
                        title: const Text('Doğum Tarihi Bilinmiyor'),
                        value: isDogumTarihiBilinmiyor,
                        onChanged: (value) {
                          setState(() {
                            isDogumTarihiBilinmiyor = value ?? false;
                            if (value == true) {
                              selectedDogumTarihi = null;
                            }
                          });
                        },
                      ),
                      if (!isDogumTarihiBilinmiyor) ...[
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedDogumTarihi ?? DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDogumTarihi = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Doğum Tarihi *',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              selectedDogumTarihi == null
                                  ? 'Tarih Seçin'
                                  : DateFormat('dd.MM.yyyy')
                                      .format(selectedDogumTarihi!),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Anne Küpe No
                      CheckboxListTile(
                        title: const Text('Anne Bilinmiyor'),
                        value: isAnneBilinmiyor,
                        onChanged: (value) {
                          setState(() {
                            isAnneBilinmiyor = value ?? false;
                            if (value == true) {
                              _anneKupeNoController.clear();
                            }
                          });
                        },
                      ),
                      if (!isAnneBilinmiyor) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _anneKupeNoController,
                          decoration: const InputDecoration(
                            labelText: 'Anne Küpe No',
                            border: OutlineInputBorder(),
                            hintText: 'TR-1234567890',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Baba Küpe No
                      CheckboxListTile(
                        title: const Text('Baba Bilinmiyor'),
                        value: isBabaBilinmiyor,
                        onChanged: (value) {
                          setState(() {
                            isBabaBilinmiyor = value ?? false;
                            if (value == true) {
                              _babaKupeNoController.clear();
                            }
                          });
                        },
                      ),
                      if (!isBabaBilinmiyor) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _babaKupeNoController,
                          decoration: const InputDecoration(
                            labelText: 'Baba Küpe No',
                            border: OutlineInputBorder(),
                            hintText: 'TR-1234567890',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Ek Bilgiler'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Chip No
                      TextFormField(
                        controller: _chipNoController,
                        decoration: const InputDecoration(
                          labelText: 'Chip No',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // RFID
                      TextFormField(
                        controller: _rfidController,
                        decoration: const InputDecoration(
                          labelText: 'RFID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ağırlık
                      TextFormField(
                        controller: _agirlikController,
                        decoration: const InputDecoration(
                          labelText: 'Ağırlık (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Durum'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Hasta'),
                        value: isHasta,
                        onChanged: (value) {
                          setState(() {
                            isHasta = value ?? false;
                          });
                        },
                      ),
                      if (selectedCinsiyet == 'D') ...[
                        CheckboxListTile(
                          title: const Text('Gebe'),
                          value: isGebe,
                          onChanged: (value) {
                            setState(() {
                              isGebe = value ?? false;
                            });
                          },
                        ),
                      ],
                      CheckboxListTile(
                        title: const Text('Satılık'),
                        value: isSatilik,
                        onChanged: (value) {
                          setState(() {
                            isSatilik = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Notlar'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _notlarController,
                    decoration: const InputDecoration(
                      labelText: 'Notlar',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _saveHayvan() {
    if (_formKey.currentState!.validate()) {
      if (!isDogumTarihiBilinmiyor && selectedDogumTarihi == null) {
        Get.snackbar(
          'Hata',
          'Lütfen doğum tarihini seçin veya bilinmiyor olarak işaretleyin',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Hayvan verilerini oluştur
      Hayvan yeniHayvan = Hayvan(
        id: 0, // ID veritabanı tarafından otomatik olarak atanacak
        kupeNo: _kupeNoController.text,
        tur: selectedTur,
        irk: selectedIrk ?? '',
        cinsiyet: selectedCinsiyet ?? '',
        dogumTarihi:
            isDogumTarihiBilinmiyor ? DateTime.now() : selectedDogumTarihi!,
        anneKupeNo: isAnneBilinmiyor ? null : _anneKupeNoController.text,
        babaKupeNo: isBabaBilinmiyor ? null : _babaKupeNoController.text,
        chipNo: _chipNoController.text,
        rfid: _rfidController.text,
        agirlik: double.tryParse(_agirlikController.text) ?? 0,
        durum: isHasta ? 'Hasta' : 'Sağlıklı',
        gebelikDurumu: isGebe,
        notlar: _notlarController.text,
        aktif: true,
        saglikDurumu: 'Sağlıklı',
        gunlukSutUretimi: 0,
        canliAgirlik: double.tryParse(_agirlikController.text) ?? 0,
        asiTakibi: [],
        tedaviGecmisi: [],
        sutVerimi: [],
        sutBilesenleri: [],
        agirlikTakibi: [],
        kizginlikTakibi: [],
      );

      // Veritabanına kaydet
      _controller.addHayvanToSuru(selectedSuruId, yeniHayvan.toMap());

      Get.snackbar(
        'Başarılı',
        'Hayvan başarıyla eklendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    }
  }
}
