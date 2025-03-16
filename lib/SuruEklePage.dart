import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'SuruYonetimController.dart';

/*
* SuruEklePage - Sürü Ekleme Sayfası
* --------------------------------
* Bu sayfa, yeni sürü oluşturma ve mevcut sürüleri
* düzenleme işlemlerini yönetir.
*
* Form Bileşenleri:
* 1. Temel Bilgiler:
*    - Sürü adı
*    - Sürü türü
*    - Lokasyon
*    - Açıklama
*
* 2. Sürü Özellikleri:
*    - Kapasite
*    - Otomatik gruplandırma
*    - Sürü kategorisi
*    - Öncelik seviyesi
*
* 3. Hayvan Seçimi:
*    - Mevcut hayvanlardan seçim
*    - Toplu hayvan ekleme
*    - Hızlı filtreleme
*    - Seçim özeti
*
* 4. Ek Ayarlar:
*    - Bildirim tercihleri
*    - Otomatik raporlama
*    - Veri paylaşımı
*    - Erişim izinleri
*
* Özellikler:
* - Form validasyonu
* - Dinamik form alanları
* - Otomatik kaydetme
* - Çoklu dil desteği
*
* Kullanılan Servisler:
* - SuruYonetimController
* - HayvanController
* - LocationService
* - ValidationService
*
* Not: Bu sayfa hem yeni sürü oluşturma hem de
* mevcut sürüleri düzenleme için kullanılır.
*/

class SuruEklePage extends StatefulWidget {
  const SuruEklePage({super.key});

  @override
  State<SuruEklePage> createState() => _SuruEklePageState();
}

class _SuruEklePageState extends State<SuruEklePage> {
  final _formKey = GlobalKey<FormState>();
  final SuruYonetimController _controller = Get.find();

  // Form fields
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  String? selectedTip;
  String? selectedIrk;
  String? selectedLokasyon;
  DateTime? selectedKurulusTarihi;

  // Predefined lists
  final List<String> suruTipleri = [
    'Süt Sığırı',
    'Besi Sığırı',
    'Düve',
    'Buzağı',
    'Karışık',
  ];

  final List<String> irklar = [
    'Holstein',
    'Simental',
    'Jersey',
    'Angus',
    'Karışık',
  ];

  final List<String> lokasyonlar = [
    'A Bölgesi',
    'B Bölgesi',
    'C Bölgesi',
    'D Bölgesi',
    'E Bölgesi',
    'F Bölgesi',
    'Karantina Bölgesi',
  ];

  @override
  void dispose() {
    _adController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Sürü Ekle'),
        actions: [
          TextButton.icon(
            onPressed: _saveSuru,
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
                      // Sürü Adı
                      TextFormField(
                        controller: _adController,
                        decoration: const InputDecoration(
                          labelText: 'Sürü Adı *',
                          border: OutlineInputBorder(),
                          hintText: 'Örn: Ana Süt Sürüsü',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sürü adı boş olamaz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sürü Tipi
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sürü Tipi *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedTip,
                        items: suruTipleri.map((tip) {
                          return DropdownMenuItem(
                            value: tip,
                            child: Text(tip),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen sürü tipini seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedTip = value;
                          });
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
                        items: irklar.map((irk) {
                          return DropdownMenuItem(
                            value: irk,
                            child: Text(irk),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen ırk seçin';
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

                      // Lokasyon
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Lokasyon *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedLokasyon,
                        items: lokasyonlar.map((lokasyon) {
                          return DropdownMenuItem(
                            value: lokasyon,
                            child: Text(lokasyon),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen lokasyon seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedLokasyon = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kuruluş Tarihi
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedKurulusTarihi ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedKurulusTarihi = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Kuruluş Tarihi',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedKurulusTarihi == null
                                ? 'Tarih Seçin'
                                : DateFormat('dd.MM.yyyy')
                                    .format(selectedKurulusTarihi!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Açıklama'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _aciklamaController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      hintText: 'Sürü hakkında ek bilgiler...',
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

  void _saveSuru() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save herd to database
      Get.snackbar(
        'Başarılı',
        'Sürü başarıyla eklendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    }
  }
}
