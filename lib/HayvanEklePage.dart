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
  String selectedTur = 'Koyun'; // Tür seçimi için varsayılan değer
  final TextEditingController _kupeNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  String? selectedIrk;
  String? selectedCinsiyet;
  DateTime? selectedDogumTarihi;
  final TextEditingController _chipNoController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _ciftlikKupeController = TextEditingController();
  String? selectedCiftlikKupeRengi;
  final TextEditingController _ulusalKupeController = TextEditingController();
  String? selectedUlusalKupeRengi = 'Sarı'; // Varsayılan değer
  final TextEditingController _anneKupeNoController = TextEditingController();
  final TextEditingController _babaKupeNoController = TextEditingController();
  final TextEditingController _agirlikController = TextEditingController();
  final TextEditingController _dogumNumarasiController = TextEditingController();
  final TextEditingController _notlarController = TextEditingController();
  final TextEditingController _ekBilgiController = TextEditingController();
  String? selectedPadokAdi;
  String? selectedDamizlikDurumu = 'Damızlık değil';
  int? selectedDamizlikPuan;
  DateTime? selectedEdinmeTarihi;
  String? selectedEdinmeYontemi;
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
    'Merinos',
    'Kıvırcık',
    'Akkaraman',
    'Morkaraman',
    'Dağlıç',
    'İvesi',
    'Sakız',
  ];

  final List<String> cinsiyetler = [
    'Erkek',
    'Dişi',
  ];

  final List<String> kupeRenkleri = [
    'Sarı',
    'Mavi',
    'Yeşil',
    'Kırmızı',
    'Beyaz',
    'Siyah',
  ];

  final List<String> damizlikDurumlari = [
    'Damızlık değil',
    'Damızlık',
  ];

  final List<String> edinmeYontemleri = [
    'Doğum',
    'Satın Alma',
    'Bağış',
    'Kiralama',
    'Diğer',
  ];

  @override
  void dispose() {
    _kupeNoController.dispose();
    _isimController.dispose();
    _chipNoController.dispose();
    _rfidController.dispose();
    _ciftlikKupeController.dispose();
    _ulusalKupeController.dispose();
    _anneKupeNoController.dispose();
    _babaKupeNoController.dispose();
    _agirlikController.dispose();
    _dogumNumarasiController.dispose();
    _notlarController.dispose();
    _ekBilgiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hayvan Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temel Bilgiler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Hayvan Türü
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Hayvan Türü',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                          helperText: 'Ayarlar bölümden koyun, keçi veya ikisi için ayarları yapabilirsiniz',
                        ),
                        value: selectedTur,
                        items: const [
                          DropdownMenuItem(
                            value: 'Koyun',
                            child: Text('Koyun'),
                          ),
                          DropdownMenuItem(
                            value: 'Keçi',
                            child: Text('Keçi'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedTur = value!;
                            // Reset irk when tur changes
                            selectedIrk = null;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir tür seçin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Cinsiyet
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Cinsiyet*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.male),
                        ),
                        value: selectedCinsiyet,
                        items: const [
                          DropdownMenuItem(
                            value: 'Erkek',
                            child: Text('Erkek'),
                          ),
                          DropdownMenuItem(
                            value: 'Dişi',
                            child: Text('Dişi'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCinsiyet = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen cinsiyet seçin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Hayvan Yaşı (otomatik)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Hayvan Yaşı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                          helperText: 'Otomatik belirlenir',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Hayvan Yaşı(g) (otomatik)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Hayvan Yaşı(g)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                          helperText: 'Otomatik belirlenir',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // İsim
                      TextFormField(
                        controller: _isimController,
                        decoration: const InputDecoration(
                          labelText: 'İsim',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // RFID Küpe Numarası
                      TextFormField(
                        controller: _rfidController,
                        decoration: const InputDecoration(
                          labelText: 'RFID Küpe Numarası*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.nfc),
                        ),
                        validator: (value) {
                          // RFID, çiftlik küpe veya ulusal küpeden en az biri zorunlu
                          if ((_rfidController.text.isEmpty &&
                              _ciftlikKupeController.text.isEmpty &&
                              _ulusalKupeController.text.isEmpty)) {
                            return 'RFID, çiftlik küpe veya ulusal küpeden en az biri gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Çiftlik Küpe
                      TextFormField(
                        controller: _ciftlikKupeController,
                        decoration: const InputDecoration(
                          labelText: 'Çiftlik Küpe*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_offer),
                        ),
                        validator: (value) {
                          // RFID, çiftlik küpe veya ulusal küpeden en az biri zorunlu
                          if ((_rfidController.text.isEmpty &&
                              _ciftlikKupeController.text.isEmpty &&
                              _ulusalKupeController.text.isEmpty)) {
                            return 'RFID, çiftlik küpe veya ulusal küpeden en az biri gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Çiftlik Küpe Rengi
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Çiftlik Küpe Rengi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.color_lens),
                        ),
                        value: selectedCiftlikKupeRengi,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('-'),
                          ),
                          DropdownMenuItem(
                            value: 'Sarı',
                            child: Text('Sarı'),
                          ),
                          DropdownMenuItem(
                            value: 'Kırmızı',
                            child: Text('Kırmızı'),
                          ),
                          DropdownMenuItem(
                            value: 'Mavi',
                            child: Text('Mavi'),
                          ),
                          DropdownMenuItem(
                            value: 'Yeşil',
                            child: Text('Yeşil'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCiftlikKupeRengi = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Ulusal Küpe
                      TextFormField(
                        controller: _ulusalKupeController,
                        decoration: const InputDecoration(
                          labelText: 'Ulusal Küpe*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) {
                          // RFID, çiftlik küpe veya ulusal küpeden en az biri zorunlu
                          if ((_rfidController.text.isEmpty &&
                              _ciftlikKupeController.text.isEmpty &&
                              _ulusalKupeController.text.isEmpty)) {
                            return 'RFID, çiftlik küpe veya ulusal küpeden en az biri gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Ulusal Küpe Rengi
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Ulusal Küpe Rengi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.palette),
                          helperText: 'Sarı',
                        ),
                        value: selectedUlusalKupeRengi,
                        items: const [
                          DropdownMenuItem(
                            value: 'Sarı',
                            child: Text('Sarı'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedUlusalKupeRengi = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Bilgilendirme metni
                      const Text(
                        'Çiftlik küpe, ulusal küpe ve RFID küpelerinden en az 1 tane girilmesi zorunludur',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Doğum Tarihi
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Doğum Tarihi*',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_month),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    selectedDogumTarihi = null;
                                  });
                                },
                              ),
                              helperText: 'gg.aa.yyyy',
                            ),
                            controller: TextEditingController(
                              text: selectedDogumTarihi != null
                                  ? '${selectedDogumTarihi!.day}.${selectedDogumTarihi!.month}.${selectedDogumTarihi!.year}'
                                  : '',
                            ),
                            validator: (value) {
                              if (!isDogumTarihiBilinmiyor && selectedDogumTarihi == null) {
                                return 'Lütfen doğum tarihi girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Damızlık durumu
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Damızlık durumu',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.star),
                        ),
                        value: selectedDamizlikDurumu,
                        items: const [
                          DropdownMenuItem(
                            value: 'Damızlık değil',
                            child: Text('Damızlık değil'),
                          ),
                          DropdownMenuItem(
                            value: 'Damızlık',
                            child: Text('Damızlık'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDamizlikDurumu = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Damızlık Puan
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Damızlık Puan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.score),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              selectedDamizlikPuan = int.tryParse(value);
                            });
                          } else {
                            setState(() {
                              selectedDamizlikPuan = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Tip Adı
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tip Adı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                          helperText: 'Otomatik belirlenir',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Irk Adı
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Irk Adı*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pest_control),
                        ),
                        value: selectedIrk,
                        items: _getIrkListesiItems(),
                        onChanged: (value) {
                          setState(() {
                            selectedIrk = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen ırk seçin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Sürü Adı
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sürü Adı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        value: null,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('-'),
                          ),
                          // Sürü listesi buraya eklenecek
                        ],
                        onChanged: (value) {
                          // Sürü değişikliği işleme
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Padok Adı
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Padok Adı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        value: selectedPadokAdi,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('-'),
                          ),
                          // Padok listesi buraya eklenecek
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPadokAdi = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Doğum Numarası
                      TextFormField(
                        controller: _dogumNumarasiController,
                        decoration: const InputDecoration(
                          labelText: 'Doğum Numarası',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Anne Küpe
                      TextFormField(
                        controller: _anneKupeNoController,
                        decoration: InputDecoration(
                          labelText: 'Anne (küpe)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.female),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // Anne arama işlevi
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Baba Küpe
                      TextFormField(
                        controller: _babaKupeNoController,
                        decoration: InputDecoration(
                          labelText: 'Baba (küpe)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.male),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // Baba arama işlevi
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Kardeş Sayısı
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Kardeş Sayısı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                          helperText: 'Otomatik belirlenir',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Kuzu Sayısı
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Kuzu Sayısı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.child_care),
                          helperText: 'Otomatik belirlenir',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Edinme Tarihi
                      GestureDetector(
                        onTap: () => _selectEdinmeTarihi(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Edinme Tarihi',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.date_range),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    selectedEdinmeTarihi = null;
                                  });
                                },
                              ),
                              helperText: 'gg.aa.yyyy',
                            ),
                            controller: TextEditingController(
                              text: selectedEdinmeTarihi != null
                                  ? '${selectedEdinmeTarihi!.day}.${selectedEdinmeTarihi!.month}.${selectedEdinmeTarihi!.year}'
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Edinme Yöntemi
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Edinme Yöntemi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_cart),
                        ),
                        value: selectedEdinmeYontemi,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('-'),
                          ),
                          DropdownMenuItem(
                            value: 'Satın Alma',
                            child: Text('Satın Alma'),
                          ),
                          DropdownMenuItem(
                            value: 'Doğum',
                            child: Text('Doğum'),
                          ),
                          DropdownMenuItem(
                            value: 'Bağış',
                            child: Text('Bağış'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedEdinmeYontemi = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Ek Bilgi
                      TextFormField(
                        controller: _ekBilgiController,
                        decoration: const InputDecoration(
                          labelText: 'Ek Bilgi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Bilgilendirme
                      const Text(
                        '* girilmesi zorunlu alanlar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveHayvan,
                  icon: const Icon(Icons.save),
                  label: const Text('Hayvanı Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _calculateAge(DateTime dogumTarihi) {
    final now = DateTime.now();
    int years = now.year - dogumTarihi.year;
    int months = now.month - dogumTarihi.month;
    int days = now.day - dogumTarihi.day;

    if (days < 0) {
      months--;
      days += 30; // Approximation
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return '$years yıl $months ay';
    } else if (months > 0) {
      return '$months ay $days gün';
    } else {
      return '$days gün';
    }
  }

  int _calculateAgeInDays(DateTime dogumTarihi) {
    final now = DateTime.now();
    return now.difference(dogumTarihi).inDays;
  }

  void _saveHayvan() {
    if (_formKey.currentState!.validate()) {
      // Kuuu no oluşturma veya kontrol et
      String kupeNo = _makeKupeNo();

      // ... Veri tabanı işlemleri

      // Başarılı kayıt
      Get.snackbar(
        'Başarılı',
        'Hayvan kaydedildi: $kupeNo',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Ana sayfaya dön
      Get.back();
    }
  }

  String _makeKupeNo() {
    // RFID, çiftlik küpe veya ulusal küpe numaralarından birini tercih et
    if (_rfidController.text.isNotEmpty) {
      return _rfidController.text;
    } else if (_ciftlikKupeController.text.isNotEmpty) {
      return _ciftlikKupeController.text;
    } else {
      return _ulusalKupeController.text;
    }
  }

  List<DropdownMenuItem<String>> _getIrkListesiItems() {
    return irklar.map((irk) {
      return DropdownMenuItem<String>(
        value: irk,
        child: Text(irk),
      );
    }).toList();
  }

  void _selectDate(BuildContext context) {
    // Implement the date selection logic here
  }

  void _selectEdinmeTarihi(BuildContext context) {
    // Implement the date selection logic here
  }
}
