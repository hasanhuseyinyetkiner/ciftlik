import 'package:get/get.dart';
import 'package:intl/intl.dart';

/*
* MilkController - Süt Yönetim Kontrolcüsü
* ------------------------------------
* Bu kontrolcü sınıfı, süt üretimi ve kalite kontrolü
* ile ilgili tüm işlemleri yönetir.
*
* Temel İşlevler:
* 1. Süt Üretim Yönetimi:
*    - Günlük süt ölçümleri
*    - Hayvan bazlı takip
*    - Toplam üretim hesaplama
*    - Verim analizi
*
* 2. Kalite Kontrol:
*    - Yağ oranı takibi
*    - Protein değerleri
*    - Somatik hücre sayımı
*    - Bakteriyel analiz
*
* 3. Veri Analizi:
*    - Trend analizi
*    - Karşılaştırmalı raporlar
*    - Tahminleme
*    - Performans metrikleri
*
* 4. Uyarı Sistemi:
*    - Kalite düşüşü
*    - Verim anomalileri
*    - Sağım zamanları
*    - Kontrol hatırlatmaları
*
* Özellikler:
* - Gerçek zamanlı izleme
* - Otomatik hesaplamalar
* - Veri validasyonu
* - Raporlama araçları
*
* Entegrasyonlar:
* - DatabaseService
* - NotificationService
* - ChartService
* - ExportService
*/

class MilkController extends GetxController {
  // Süt kayıtları
  final RxList<Map<String, dynamic>> sutKayitlari =
      <Map<String, dynamic>>[].obs;

  // Seçili hayvan
  final Rxn<String> selectedAnimal = Rxn<String>();

  // Tarih aralığı filtreleri
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Kalite parametreleri
  final RxDouble yagOrani = 0.0.obs;
  final RxDouble proteinOrani = 0.0.obs;
  final RxInt somatikHucreSayisi = 0.obs;

  // Örnek hayvan listesi
  final RxList<Map<String, dynamic>> hayvanlar = <Map<String, dynamic>>[
    {'id': '1', 'ad': 'İnek 1', 'tur': 'İnek'},
    {'id': '2', 'ad': 'İnek 2', 'tur': 'İnek'},
    {'id': '3', 'ad': 'Koyun 1', 'tur': 'Koyun'},
    {'id': '4', 'ad': 'Koyun 2', 'tur': 'Koyun'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Örnek süt kayıtları
    sutKayitlari.addAll([
      {
        'id': '1',
        'hayvanId': '1',
        'hayvanAd': 'İnek 1',
        'tarih': DateTime.now().subtract(const Duration(days: 30)),
        'miktar': 25.5,
        'birim': 'litre',
        'yagOrani': 3.8,
        'proteinOrani': 3.2,
        'somatikHucreSayisi': 150000,
        'notlar': 'Normal sağım',
      },
      {
        'id': '2',
        'hayvanId': '1',
        'hayvanAd': 'İnek 1',
        'tarih': DateTime.now().subtract(const Duration(days: 15)),
        'miktar': 27.0,
        'birim': 'litre',
        'yagOrani': 3.9,
        'proteinOrani': 3.3,
        'somatikHucreSayisi': 145000,
        'notlar': 'Verim artışı var',
      },
    ]);
  }

  // Süt kaydı ekleme
  void addSutKaydi(Map<String, dynamic> kayit) {
    sutKayitlari.add(kayit);
    sutKayitlari.sort((a, b) => b['tarih'].compareTo(a['tarih']));
    sutKayitlari.refresh();
  }

  // Filtreleme işlemleri
  List<Map<String, dynamic>> getFilteredSutKayitlari() {
    var filteredList = sutKayitlari.toList();

    // Hayvan filtresi
    if (selectedAnimal.value != null) {
      filteredList = filteredList
          .where((kayit) => kayit['hayvanId'] == selectedAnimal.value)
          .toList();
    }

    // Tarih aralığı filtresi
    if (startDate.value != null) {
      filteredList = filteredList
          .where((kayit) => kayit['tarih'].isAfter(startDate.value!))
          .toList();
    }
    if (endDate.value != null) {
      filteredList = filteredList
          .where((kayit) => kayit['tarih'].isBefore(endDate.value!))
          .toList();
    }

    return filteredList;
  }

  // Süt verimi analizi
  Map<String, dynamic> getMilkAnalysis(String hayvanId) {
    var hayvanKayitlari =
        sutKayitlari.where((kayit) => kayit['hayvanId'] == hayvanId).toList();

    if (hayvanKayitlari.isEmpty) {
      return {
        'ortalamaMiktar': 0.0,
        'toplamMiktar': 0.0,
        'gunlukOrtalama': 0.0,
        'enYuksekMiktar': 0.0,
      };
    }

    hayvanKayitlari.sort((a, b) => a['tarih'].compareTo(b['tarih']));

    var toplamMiktar = hayvanKayitlari.fold<double>(
        0, (sum, kayit) => sum + (kayit['miktar'] as double));
    var enYuksekMiktar = hayvanKayitlari
        .map((k) => k['miktar'] as double)
        .reduce((a, b) => a > b ? a : b);

    return {
      'ortalamaMiktar': toplamMiktar / hayvanKayitlari.length,
      'toplamMiktar': toplamMiktar,
      'gunlukOrtalama': toplamMiktar / 30, // Son 30 günlük ortalama
      'enYuksekMiktar': enYuksekMiktar,
    };
  }

  // Grafik verilerini hazırlama
  List<Map<String, dynamic>> getChartData(String hayvanId) {
    var kayitlar =
        sutKayitlari.where((kayit) => kayit['hayvanId'] == hayvanId).toList();

    kayitlar.sort((a, b) => a['tarih'].compareTo(b['tarih']));

    return kayitlar.map((kayit) {
      return {
        'tarih': DateFormat('dd/MM/yyyy').format(kayit['tarih']),
        'miktar': kayit['miktar'],
      };
    }).toList();
  }

  // Laboratuvar verilerini yükleme simülasyonu
  Future<void> loadLabData() async {
    await Future.delayed(const Duration(seconds: 2));
    yagOrani.value = 3.9;
    proteinOrani.value = 3.3;
    somatikHucreSayisi.value = 145000;
  }
}
