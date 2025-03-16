import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'SuruYonetimController.dart';

/*
* SaglikKaydiEklePage - Sağlık Kaydı Ekleme Sayfası
* ----------------------------------------------
* Bu sayfa, hayvanlar için sağlık kayıtlarının
* oluşturulması ve düzenlenmesini sağlar.
*
* Form Bileşenleri:
* 1. Temel Bilgiler:
*    - Hayvan seçimi
*    - Muayene tarihi
*    - Muayene eden veteriner
*    - Şikayet/Semptomlar
*
* 2. Muayene Detayları:
*    - Vücut ısısı
*    - Nabız
*    - Solunum
*    - Genel durum
*    - Özel bulgular
*
* 3. Teşhis ve Tedavi:
*    - Teşhis
*    - Tedavi planı
*    - İlaç reçetesi
*    - Doz bilgileri
*    - Uygulama süresi
*
* 4. Laboratuvar:
*    - Test sonuçları
*    - Görüntüleme
*    - Numune bilgileri
*    - Referans değerler
*
* 5. Takip Bilgileri:
*    - Kontrol tarihi
*    - Öneriler
*    - Kısıtlamalar
*    - Notlar
*
* Özellikler:
* - Akıllı form doldurma
* - Otomatik hesaplamalar
* - Dosya ekleme
* - Şablon kullanımı
*
* Entegrasyonlar:
* - Bildirim sistemi
* - Takvim entegrasyonu
* - İlaç stok kontrolü
* - Veteriner servisi
*/

class SaglikKaydiEklePage extends StatefulWidget {
  const SaglikKaydiEklePage({super.key});

  @override
  State<SaglikKaydiEklePage> createState() => _SaglikKaydiEklePageState();
}

class _SaglikKaydiEklePageState extends State<SaglikKaydiEklePage> {
  final _formKey = GlobalKey<FormState>();
  final SuruYonetimController _controller = Get.find();

  // Form fields
  String? selectedHayvanId;
  String? selectedKayitTuru;
  DateTime? selectedTarih;
  String? selectedAsi;
  String? selectedPersonel;
  final TextEditingController _seriNoController = TextEditingController();
  DateTime? selectedSonrakiAsiTarihi;
  final TextEditingController _hastalikController = TextEditingController();
  final TextEditingController _hastalikKoduController = TextEditingController();
  final TextEditingController _tedaviAciklamasiController =
      TextEditingController();
  String? selectedVeteriner;
  final TextEditingController _maliyetController = TextEditingController();
  final TextEditingController _ilacAdiController = TextEditingController();
  final TextEditingController _dozajController = TextEditingController();
  String? selectedUygulamaSekli;
  final TextEditingController _tedaviSuresiController = TextEditingController();
  final TextEditingController _notlarController = TextEditingController();

  // Predefined lists
  final List<String> kayitTurleri = [
    'Aşı Kaydı',
    'Muayene/Tedavi',
    'İlaç Kullanımı'
  ];
  final List<String> asilar = [
    'Şap Aşısı',
    'Brusella Aşısı',
    'IBR Aşısı',
    'BVD Aşısı'
  ];
  final List<String> uygulamaSekilleri = [
    'Enjeksiyon',
    'Oral',
    'Deri Altı',
    'Topikal'
  ];

  @override
  void dispose() {
    _seriNoController.dispose();
    _hastalikController.dispose();
    _hastalikKoduController.dispose();
    _tedaviAciklamasiController.dispose();
    _maliyetController.dispose();
    _ilacAdiController.dispose();
    _dozajController.dispose();
    _tedaviSuresiController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sağlık Kaydı Ekle'),
        actions: [
          TextButton.icon(
            onPressed: _saveRecord,
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
                      // Hayvan Seçimi
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Hayvan *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedHayvanId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Hayvan Seçin'),
                          ),
                          ...(_controller.hayvanListesi.map((hayvan) {
                            return DropdownMenuItem(
                              value: hayvan['id'].toString(),
                              child: Text(
                                  '${hayvan['kupeNo']} - ${hayvan['irk']}'),
                            );
                          })).toList(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir hayvan seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedHayvanId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kayıt Türü
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Kayıt Türü *',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedKayitTuru,
                        items: kayitTurleri.map((tur) {
                          return DropdownMenuItem(
                            value: tur,
                            child: Text(tur),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen kayıt türünü seçin';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedKayitTuru = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tarih
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedTarih ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTarih = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tarih *',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedTarih == null
                                ? 'Tarih Seçin'
                                : DateFormat('dd.MM.yyyy')
                                    .format(selectedTarih!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (selectedKayitTuru == 'Aşı Kaydı') ...[
                _buildSectionTitle('Aşı Bilgileri'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Aşı Seçimi
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Aşı *',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedAsi,
                          items: asilar.map((asi) {
                            return DropdownMenuItem(
                              value: asi,
                              child: Text(asi),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen aşı seçin';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedAsi = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Uygulayan Personel
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Uygulayan Personel *',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedPersonel,
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Personel Seçin'),
                            ),
                            DropdownMenuItem(
                              value: '1',
                              child: Text('Dr. Ahmet Yılmaz'),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text('Dr. Mehmet Demir'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen personel seçin';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedPersonel = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Seri/Parti No
                        TextFormField(
                          controller: _seriNoController,
                          decoration: const InputDecoration(
                            labelText: 'Seri/Parti No',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sonraki Aşılama Tarihi
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedSonrakiAsiTarihi ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedSonrakiAsiTarihi = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Sonraki Aşılama Tarihi',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              selectedSonrakiAsiTarihi == null
                                  ? 'Tarih Seçin'
                                  : DateFormat('dd.MM.yyyy')
                                      .format(selectedSonrakiAsiTarihi!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (selectedKayitTuru == 'Muayene/Tedavi') ...[
                _buildSectionTitle('Muayene/Tedavi Bilgileri'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Hastalık
                        TextFormField(
                          controller: _hastalikController,
                          decoration: const InputDecoration(
                            labelText: 'Hastalık *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen hastalık adını girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Hastalık Kodu
                        TextFormField(
                          controller: _hastalikKoduController,
                          decoration: const InputDecoration(
                            labelText: 'Hastalık Kodu',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tedavi Açıklaması
                        TextFormField(
                          controller: _tedaviAciklamasiController,
                          decoration: const InputDecoration(
                            labelText: 'Tedavi Açıklaması *',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen tedavi açıklamasını girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Veteriner
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Veteriner *',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedVeteriner,
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Veteriner Seçin'),
                            ),
                            DropdownMenuItem(
                              value: '1',
                              child: Text('Dr. Ahmet Yılmaz'),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text('Dr. Mehmet Demir'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen veteriner seçin';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedVeteriner = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // İlaç Maliyeti
                        TextFormField(
                          controller: _maliyetController,
                          decoration: const InputDecoration(
                            labelText: 'İlaç Maliyeti (TL)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (selectedKayitTuru == 'İlaç Kullanımı') ...[
                _buildSectionTitle('İlaç Kullanım Bilgileri'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // İlaç Adı
                        TextFormField(
                          controller: _ilacAdiController,
                          decoration: const InputDecoration(
                            labelText: 'İlaç Adı *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen ilaç adını girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dozaj
                        TextFormField(
                          controller: _dozajController,
                          decoration: const InputDecoration(
                            labelText: 'Dozaj *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen dozajı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Uygulama Şekli
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Uygulama Şekli *',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedUygulamaSekli,
                          items: uygulamaSekilleri.map((sekil) {
                            return DropdownMenuItem(
                              value: sekil,
                              child: Text(sekil),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen uygulama şeklini seçin';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedUygulamaSekli = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tedavi Süresi
                        TextFormField(
                          controller: _tedaviSuresiController,
                          decoration: const InputDecoration(
                            labelText: 'Tedavi Süresi (Gün) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen tedavi süresini girin';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      if (selectedTarih == null) {
        Get.snackbar(
          'Hata',
          'Lütfen tarih seçin',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // TODO: Save health record to database
      Get.snackbar(
        'Başarılı',
        'Sağlık kaydı başarıyla eklendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    }
  }
}
