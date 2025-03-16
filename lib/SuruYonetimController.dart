import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

/*
* SuruYonetimController - Sürü Yönetim Kontrolcüsü
* ----------------------------------------------
* Bu kontrolcü sınıfı, çiftlikteki sürülerin ve hayvan gruplarının
* yönetiminden sorumludur.
*
* Temel Özellikler:
* 1. Sürü Yönetimi:
*    - Sürü oluşturma ve düzenleme
*    - Sürü silme ve arşivleme
*    - Sürü detay görüntüleme
*    - Sürü istatistikleri
*
* 2. Hayvan Grup İşlemleri:
*    - Gruplara hayvan ekleme/çıkarma
*    - Grup transferleri
*    - Otomatik grup önerileri
*    - Grup performans takibi
*
* 3. Sürü Sağlığı:
*    - Toplu aşılama planları
*    - Salgın takibi
*    - Karantina yönetimi
*    - Sağlık taramaları
*
* 4. Üreme Yönetimi:
*    - Çiftleştirme planları
*    - Gebelik takibi
*    - Doğum programı
*    - Genetik kayıtlar
*
* 5. Verimlilik Analizi:
*    - Süt verimi takibi
*    - Yem tüketimi analizi
*    - Büyüme performansı
*    - Ekonomik analiz
*
* Önemli Metodlar:
* - createSuru(): Yeni sürü oluşturur
* - updateSuru(): Sürü bilgilerini günceller
* - deleteSuru(): Sürü kaydını siler
* - transferHayvan(): Hayvanları gruplar arası transfer eder
* - calculateMetrics(): Sürü metriklerini hesaplar
*
* Bağımlılıklar:
* - HayvanController: Hayvan yönetimi
* - DatabaseService: Veritabanı işlemleri
* - NotificationService: Bildirim yönetimi
*/

class TimeSeriesSales {
  final DateTime time;
  final double sales;
  final String? animalId;
  final String? animalName;

  TimeSeriesSales(this.time, this.sales, {this.animalId, this.animalName});
}

class ChartPieSegment {
  final String segment;
  final int size;
  final Color color;

  ChartPieSegment(this.segment, this.size, this.color);
}

class SuruYonetimController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var suruListesi = <Map<String, dynamic>>[].obs;
  var filteredSuruListesi = <Map<String, dynamic>>[].obs;
  var hayvanListesi = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'Tümü'.obs;
  var selectedSortOption = 'Ad (A-Z)'.obs;
  var selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  ).obs;
  var viewType = 'list'.obs; // 'list' or 'grid'
  var selectedSurular = <int>[].obs;
  var isBatchMode = false.obs;

  late TabController tabController;
  final filterOptions = [
    'Tümü',
    'Büyükbaş',
    'Küçükbaş',
    'Aktif',
    'Arşiv',
    'Karantina',
  ];
  final sortOptions = [
    'Ad (A-Z)',
    'Ad (Z-A)',
    'Hayvan Sayısı (Azalan)',
    'Hayvan Sayısı (Artan)',
    'Tarih (Yeni-Eski)',
    'Tarih (Eski-Yeni)',
    'Verim (Yüksek-Düşük)',
    'Verim (Düşük-Yüksek)',
  ];

  final Map<String, List<String>> advancedFilters = {
    'Irk': ['Tümü', 'Holstein', 'Simental', 'Merinos', 'Kıvırcık'],
    'Sağlık Durumu': ['Tümü', 'Sağlıklı', 'Hasta', 'Karantina'],
    'Lokasyon': [
      'Tümü',
      'Ana Ahır',
      'Buzağı Ahırı',
      'Mera',
      'Karantina Bölgesi'
    ],
  };

  final selectedAdvancedFilters = {
    'Irk': 'Tümü',
    'Sağlık Durumu': 'Tümü',
    'Lokasyon': 'Tümü',
  }.obs;

  // Statistics Properties
  var selectedSuruId = 'all'.obs;
  var selectedPeriod = 'daily'.obs;
  var statisticsLoading = false.obs;
  var sutVerimiData = <TimeSeriesSales>[].obs;
  var saglikDurumuData = <ChartPieSegment>[].obs;
  var irkDagitimiData = <Map<String, dynamic>>[].obs;
  var ozet = <Map<String, dynamic>>[].obs;

  // Helper methods for RxList conversion
  List<TimeSeriesSales>? get sutVerimiList =>
      sutVerimiData.isEmpty ? null : sutVerimiData.toList();
  List<ChartPieSegment>? get saglikDurumuList =>
      saglikDurumuData.isEmpty ? null : saglikDurumuData.toList();
  List<Map<String, dynamic>>? get irkDagitimiList =>
      irkDagitimiData.isEmpty ? null : irkDagitimiData.toList();

  var agirlikTakipList = <TimeSeriesSales>[].obs;
  var sutBilesenList = <Map<String, dynamic>>[].obs;
  var kuruDonemList = <Map<String, dynamic>>[].obs;
  var kizginlikTakipList = <Map<String, dynamic>>[].obs;
  var notlarList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    fetchSuruler();
    fetchStatistics();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchSuruler() async {
    isLoading(true);
    try {
      // TODO: Implement actual database fetch
      // Temporary mock data
      await Future.delayed(const Duration(seconds: 1));
      // Fetch data from the database here
      suruListesi.value = [
        {
          'id': 1,
          'ad': 'Ana Süt Sürüsü',
          'tip': 'Süt Sığırı',
          'irk': 'Holstein',
          'aciklama': 'Ana süt üretim sürüsü',
          'hayvanSayisi': 150,
          'aktifHayvanSayisi': 145,
          'hastaHayvanSayisi': 2,
          'gebeSayisi': 45,
          'lokasyon': 'Ana Ahır',
          'olusturmaTarihi': DateTime.now().subtract(const Duration(days: 365)),
          'sonGuncelleme': DateTime.now(),
          'verimOrtalaması': 28.5,
          'durum': 'Aktif',
        },
        {
          'id': 2,
          'ad': 'Genç Sürü',
          'tip': 'Düve',
          'irk': 'Holstein',
          'aciklama': 'Gelecek nesil süt sürüsü',
          'hayvanSayisi': 75,
          'aktifHayvanSayisi': 73,
          'hastaHayvanSayisi': 1,
          'gebeSayisi': 0,
          'lokasyon': 'B Bölgesi',
          'olusturmaTarihi': DateTime.now().subtract(const Duration(days: 180)),
          'sonGuncelleme': DateTime.now(),
          'verimOrtalaması': 0,
          'durum': 'Aktif',
        },
        {
          'id': 3,
          'ad': 'Simental Sürüsü',
          'tip': 'Süt Sığırı',
          'irk': 'Simental',
          'aciklama': 'Simental ırkı süt sürüsü',
          'hayvanSayisi': 85,
          'aktifHayvanSayisi': 82,
          'hastaHayvanSayisi': 1,
          'gebeSayisi': 25,
          'lokasyon': 'C Bölgesi',
          'olusturmaTarihi': DateTime.now().subtract(const Duration(days: 240)),
          'sonGuncelleme': DateTime.now(),
          'verimOrtalaması': 25.8,
          'durum': 'Aktif',
        },
        {
          'id': 4,
          'ad': 'Kuru Dönem Sürüsü',
          'tip': 'Süt Sığırı',
          'irk': 'Karışık',
          'aciklama': 'Kuru dönemdeki inekler',
          'hayvanSayisi': 35,
          'aktifHayvanSayisi': 35,
          'hastaHayvanSayisi': 0,
          'gebeSayisi': 35,
          'lokasyon': 'D Bölgesi',
          'olusturmaTarihi': DateTime.now().subtract(const Duration(days: 120)),
          'sonGuncelleme': DateTime.now(),
          'verimOrtalaması': 0,
          'durum': 'Aktif',
        },
        {
          'id': 5,
          'ad': 'Karantina Sürüsü',
          'tip': 'Karışık',
          'irk': 'Karışık',
          'aciklama': 'Karantina altındaki hayvanlar',
          'hayvanSayisi': 8,
          'aktifHayvanSayisi': 6,
          'hastaHayvanSayisi': 2,
          'gebeSayisi': 0,
          'lokasyon': 'Karantina Bölgesi',
          'olusturmaTarihi': DateTime.now().subtract(const Duration(days: 30)),
          'sonGuncelleme': DateTime.now(),
          'verimOrtalaması': 0,
          'durum': 'Karantina',
        },
      ];

      _filterAndSortSuruler();
    } catch (e) {
      // Improved error handling
      Get.snackbar(
        'Hata',
        'Sürü verileri alınırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error fetching sürüler: $e');
    } finally {
      isLoading(false);
    }
  }

  void _filterAndSortSuruler() {
    var filtered = List<Map<String, dynamic>>.from(suruListesi);

    if (selectedFilter.value != 'Tümü') {
      if (selectedFilter.value == 'Aktif' ||
          selectedFilter.value == 'Arşiv' ||
          selectedFilter.value == 'Karantina') {
        filtered = filtered
            .where((suru) => suru['durum'] == selectedFilter.value)
            .toList();
      } else {
        filtered = filtered
            .where((suru) => suru['tip'] == selectedFilter.value)
            .toList();
      }
    }

    selectedAdvancedFilters.forEach((key, value) {
      if (value != 'Tümü') {
        filtered =
            filtered.where((suru) => suru[key.toLowerCase()] == value).toList();
      }
    });

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((suru) {
        return suru['ad'].toString().toLowerCase().contains(query) ||
            suru['aciklama'].toString().toLowerCase().contains(query) ||
            suru['lokasyon'].toString().toLowerCase().contains(query) ||
            (suru['sorumlu'] != null &&
                suru['sorumlu'].toString().toLowerCase().contains(query)) ||
            suru['irk'].toString().toLowerCase().contains(query);
      }).toList();
    }

    filtered = filtered.where((suru) {
      final date = suru['olusturmaTarihi'] as DateTime;
      return date.isAfter(selectedDateRange.value.start) &&
          date.isBefore(
              selectedDateRange.value.end.add(const Duration(days: 1)));
    }).toList();

    switch (selectedSortOption.value) {
      case 'Ad (A-Z)':
        filtered
            .sort((a, b) => a['ad'].toString().compareTo(b['ad'].toString()));
        break;
      case 'Ad (Z-A)':
        filtered
            .sort((a, b) => b['ad'].toString().compareTo(a['ad'].toString()));
        break;
      case 'Hayvan Sayısı (Azalan)':
        filtered.sort((a, b) => b['hayvanSayisi'].compareTo(a['hayvanSayisi']));
        break;
      case 'Hayvan Sayısı (Artan)':
        filtered.sort((a, b) => a['hayvanSayisi'].compareTo(b['hayvanSayisi']));
        break;
      case 'Tarih (Yeni-Eski)':
        filtered.sort((a, b) => (b['olusturmaTarihi'] as DateTime)
            .compareTo(a['olusturmaTarihi'] as DateTime));
        break;
      case 'Tarih (Eski-Yeni)':
        filtered.sort((a, b) => (a['olusturmaTarihi'] as DateTime)
            .compareTo(b['olusturmaTarihi'] as DateTime));
        break;
      case 'Verim (Yüksek-Düşük)':
        filtered.sort(
            (a, b) => b['verimOrtalaması'].compareTo(a['verimOrtalaması']));
        break;
      case 'Verim (Düşük-Yüksek)':
        filtered.sort(
            (a, b) => a['verimOrtalaması'].compareTo(b['verimOrtalaması']));
        break;
    }

    filteredSuruListesi.value = filtered;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _filterAndSortSuruler();
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    _filterAndSortSuruler();
  }

  void updateSortOption(String option) {
    selectedSortOption.value = option;
    _filterAndSortSuruler();
  }

  void updateDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
    _filterAndSortSuruler();
  }

  void updateAdvancedFilter(String filterType, String value) {
    selectedAdvancedFilters[filterType] = value;
    _filterAndSortSuruler();
  }

  void toggleViewType() {
    viewType.value = viewType.value == 'list' ? 'grid' : 'list';
  }

  void toggleBatchMode() {
    isBatchMode.value = !isBatchMode.value;
    if (!isBatchMode.value) {
      selectedSurular.clear();
    }
  }

  void toggleSuruSelection(int suruId) {
    if (selectedSurular.contains(suruId)) {
      selectedSurular.remove(suruId);
    } else {
      selectedSurular.add(suruId);
    }
  }

  String getStatusColor(String durum) {
    switch (durum) {
      case 'Aktif':
        return '#4CAF50';
      case 'Arşiv':
        return '#9E9E9E';
      case 'Karantina':
        return '#FFC107';
      default:
        return '#2196F3';
    }
  }

  String formatNumber(num value) {
    return NumberFormat.compact().format(value);
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g önce';
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  Future<void> performBatchOperation(String operation) async {
    if (selectedSurular.isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen en az bir sürü seçin');
      return;
    }

    try {
      isLoading(true);
      // TODO: Implement actual batch operations
      await Future.delayed(const Duration(seconds: 1));

      switch (operation) {
        case 'archive':
          // TODO: Archive selected sürüler
          break;
        case 'delete':
          // TODO: Delete selected sürüler
          break;
        case 'move':
          // TODO: Move selected sürüler
          break;
        default:
          throw Exception('Unknown operation: $operation');
      }

      Get.snackbar('Başarılı', 'İşlem başarıyla tamamlandı');
      selectedSurular.clear();
      isBatchMode(false);
      await fetchSuruler();
    } catch (e) {
      Get.snackbar('Hata', 'İşlem sırasında bir hata oluştu: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchStatistics() async {
    statisticsLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Süt verimi verileri
      sutVerimiData.value = List.generate(30, (index) {
        final date = DateTime.now().subtract(Duration(days: 29 - index));
        return TimeSeriesSales(date, Random().nextDouble() * 1000 + 2000);
      });

      // Ağırlık takip verileri
      agirlikTakipList.value = List.generate(12, (index) {
        final date = DateTime.now().subtract(Duration(days: (11 - index) * 30));
        return TimeSeriesSales(date, Random().nextDouble() * 50 + 600,
            animalId: 'TR-123456789', animalName: 'Holstein-1');
      });

      // Süt bileşenleri verileri
      sutBilesenList.value = List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 6 - index));
        return {
          'tarih': date,
          'yag': (Random().nextDouble() * 1 + 3.5).toStringAsFixed(1),
          'protein': (Random().nextDouble() * 0.5 + 3.0).toStringAsFixed(1),
          'shs': (Random().nextInt(200) + 100).toString() + 'K',
        };
      });

      // Kuru dönem verileri
      kuruDonemList.value = [
        {
          'kupeNo': 'TR123456789',
          'kalanGun': 45,
          'planliTarih': DateTime.now().add(const Duration(days: 45)),
        },
        {
          'kupeNo': 'TR987654321',
          'kalanGun': 30,
          'planliTarih': DateTime.now().add(const Duration(days: 30)),
        },
      ];

      // Kızgınlık takip verileri
      kizginlikTakipList.value = [
        {
          'kupeNo': 'TR123456789',
          'sonKizginlik': DateTime.now().subtract(const Duration(days: 21)),
          'durum': 'Normal',
        },
        {
          'kupeNo': 'TR987654321',
          'sonKizginlik': DateTime.now().subtract(const Duration(days: 5)),
          'durum': 'Yaklaşıyor',
        },
      ];

      // Notlar ve hatırlatmalar
      notlarList.value = [
        {
          'baslik': 'Kontrol Gerekiyor',
          'icerik':
              'TR123456789 numaralı hayvanın sağ arka ayağında topallık var.',
          'tarih': DateTime.now().subtract(const Duration(days: 2)),
          'tip': 'Önemli',
        },
        {
          'baslik': 'Aşı Hatırlatması',
          'icerik': 'Gelecek hafta şap aşısı yapılacak hayvanlar.',
          'tarih': DateTime.now().subtract(const Duration(days: 1)),
          'tip': 'Hatırlatma',
        },
      ];

      // Fetch summary data
      ozet.value = [
        {
          'title': 'Toplam Hayvan',
          'value': '450',
          'icon': 'pets',
          'color': '#2196F3',
          'subtitle': '+12 son 30 günde',
        },
        {
          'title': 'Aktif Hayvan',
          'value': '438',
          'icon': 'check_circle',
          'color': '#4CAF50',
          'subtitle': '97.3% aktif',
        },
        {
          'title': 'Hasta Hayvan',
          'value': '3',
          'icon': 'medical_services',
          'color': '#F44336',
          'subtitle': '0.7% hasta',
        },
        {
          'title': 'Gebe Hayvan',
          'value': '165',
          'icon': 'pregnant_woman',
          'color': '#9C27B0',
          'subtitle': '37.6% gebe',
        },
        {
          'title': 'Günlük Süt',
          'value': '2,875L',
          'icon': 'water_drop',
          'color': '#00BCD4',
          'subtitle': '+125L dünden',
        },
      ];

      // Fetch health status data
      saglikDurumuData.value = [
        ChartPieSegment('Sağlıklı', 438, Colors.green),
        ChartPieSegment('Hasta', 3, Colors.red),
        ChartPieSegment('Karantina', 9, Colors.orange),
      ];

      // Fetch breed distribution data
      irkDagitimiData.value = [
        {'irk': 'Holstein', 'sayi': 180},
        {'irk': 'Simental', 'sayi': 120},
        {'irk': 'Merinos', 'sayi': 90},
        {'irk': 'Kıvırcık', 'sayi': 60},
      ];
    } catch (e) {
      print('Error fetching statistics: $e');
      Get.snackbar(
        'Hata',
        'İstatistikler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      statisticsLoading(false);
    }
  }

  void updateSelectedSuru(String? suruId) {
    if (suruId != null) {
      selectedSuruId.value = suruId;
      fetchStatistics();
    }
  }

  void updateSelectedPeriod(String? period) {
    if (period != null) {
      selectedPeriod.value = period;
      fetchStatistics();
    }
  }

  // Report Generation Methods
  Future<void> generateReport(String reportType) async {
    try {
      statisticsLoading(true);

      // Prepare report data based on type
      Map<String, dynamic> reportData = {};
      String reportTitle = '';

      switch (reportType) {
        case 'performance':
          reportTitle = 'Sürü Performans Raporu';
          reportData = await _generatePerformanceReport();
          break;
        case 'health':
          reportTitle = 'Sağlık Raporu';
          reportData = await _generateHealthReport();
          break;
        case 'reproduction':
          reportTitle = 'Üreme Raporu';
          reportData = await _generateReproductionReport();
          break;
        case 'milk':
          reportTitle = 'Süt Verimi Raporu';
          reportData = await _generateMilkReport();
          break;
        case 'financial':
          reportTitle = 'Finansal Rapor';
          reportData = await _generateFinancialReport();
          break;
        case 'feed':
          reportTitle = 'Yem Tüketim Raporu';
          reportData = await _generateFeedReport();
          break;
        case 'custom':
          reportTitle = 'Özel Rapor';
          reportData = await _generateCustomReport();
          break;
        default:
          throw Exception('Geçersiz rapor tipi: $reportType');
      }

      // Show report preview dialog
      Get.dialog(
        _buildReportPreviewDialog(reportTitle, reportData),
        barrierDismissible: true,
      );
    } catch (e) {
      print('Error generating report: $e');
      Get.snackbar(
        'Hata',
        'Rapor oluşturulurken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      statisticsLoading(false);
    }
  }

  Future<void> generateCustomReport() async {
    try {
      // Show custom report builder dialog
      final result = await Get.dialog(
        _buildCustomReportDialog(),
        barrierDismissible: true,
      );

      if (result != null) {
        // Generate custom report with selected metrics
        await generateReport('custom');
      }
    } catch (e) {
      print('Error generating custom report: $e');
      Get.snackbar(
        'Hata',
        'Özel rapor oluşturulurken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Private report generation methods
  Future<Map<String, dynamic>> _generatePerformanceReport() async {
    // TODO: Implement actual performance report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Toplam Hayvan Sayısı',
          'value': '450',
          'change': '+12',
          'period': 'son 30 gün',
        },
        {
          'title': 'Ortalama Süt Verimi',
          'value': '25.5L',
          'change': '+1.2L',
          'period': 'geçen aya göre',
        },
        // Add more metrics
      ],
      'charts': [
        {
          'type': 'line',
          'title': 'Süt Verimi Trendi',
          'data': sutVerimiData,
        },
        // Add more charts
      ],
    };
  }

  Future<Map<String, dynamic>> _generateHealthReport() async {
    // TODO: Implement actual health report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Sağlıklı Hayvan',
          'value': '438',
          'percentage': '97.3%',
        },
        {
          'title': 'Hasta Hayvan',
          'value': '3',
          'percentage': '0.7%',
        },
        // Add more metrics
      ],
      'treatments': [
        {
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'animal': 'TR123456789',
          'condition': 'Mastitis',
          'treatment': 'Antibiyotik',
          'vet': 'Dr. Ahmet Yılmaz',
        },
        // Add more treatments
      ],
    };
  }

  Future<Map<String, dynamic>> _generateReproductionReport() async {
    // TODO: Implement actual reproduction report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Gebe Hayvan',
          'value': '165',
          'percentage': '37.6%',
        },
        {
          'title': 'Beklenen Doğumlar',
          'value': '45',
          'period': 'gelecek 30 gün',
        },
        // Add more metrics
      ],
      'pregnancies': [
        {
          'animal': 'TR123456789',
          'inseminationDate': DateTime.now().subtract(const Duration(days: 90)),
          'expectedBirthDate': DateTime.now().add(const Duration(days: 180)),
          'status': 'Normal',
        },
        // Add more pregnancies
      ],
    };
  }

  Future<Map<String, dynamic>> _generateMilkReport() async {
    // TODO: Implement actual milk report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Günlük Süt Üretimi',
          'value': '2,875L',
          'change': '+125L',
          'period': 'dünden',
        },
        {
          'title': 'Aylık Süt Üretimi',
          'value': '85,250L',
          'change': '+2,500L',
          'period': 'geçen aya göre',
        },
        // Add more metrics
      ],
      'quality': {
        'fat': '3.8%',
        'protein': '3.2%',
        'scc': '150,000',
        'bacteria': '25,000',
      },
    };
  }

  Future<Map<String, dynamic>> _generateFinancialReport() async {
    // TODO: Implement actual financial report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Toplam Gelir',
          'value': '₺125,000',
          'change': '+₺15,000',
          'period': 'geçen aya göre',
        },
        {
          'title': 'Toplam Gider',
          'value': '₺85,000',
          'change': '+₺5,000',
          'period': 'geçen aya göre',
        },
        // Add more metrics
      ],
      'expenses': [
        {
          'category': 'Yem',
          'amount': '₺45,000',
          'percentage': '52.9%',
        },
        {
          'category': 'İşçilik',
          'amount': '₺20,000',
          'percentage': '23.5%',
        },
        // Add more expenses
      ],
    };
  }

  Future<Map<String, dynamic>> _generateFeedReport() async {
    // TODO: Implement actual feed report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Günlük Yem Tüketimi',
          'value': '2,250kg',
          'change': '-50kg',
          'period': 'dünden',
        },
        {
          'title': 'Yem Stoku',
          'value': '15,000kg',
          'duration': '20 gün',
        },
        // Add more metrics
      ],
      'inventory': [
        {
          'type': 'Kaba Yem',
          'stock': '8,000kg',
          'daily': '1,200kg',
          'duration': '6.7 gün',
        },
        {
          'type': 'Kesif Yem',
          'stock': '7,000kg',
          'daily': '1,050kg',
          'duration': '6.7 gün',
        },
        // Add more inventory
      ],
    };
  }

  Future<Map<String, dynamic>> _generateCustomReport() async {
    // TODO: Implement actual custom report generation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'metrics': [
        {
          'title': 'Özel Metrik 1',
          'value': '100',
          'change': '+10',
          'period': 'son 7 gün',
        },
        {
          'title': 'Özel Metrik 2',
          'value': '200',
          'change': '-20',
          'period': 'son 7 gün',
        },
      ],
      'charts': [
        {
          'type': 'line',
          'title': 'Özel Grafik 1',
          'data': sutVerimiData,
        },
        {
          'type': 'pie',
          'title': 'Özel Grafik 2',
          'data': saglikDurumuData,
        },
      ],
    };
  }

  Widget _buildReportPreviewDialog(String title, Map<String, dynamic> data) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.9,
          maxHeight: Get.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: () => _printReport(title, data),
                        tooltip: 'Yazdır',
                      ),
                      IconButton(
                        icon: const Icon(Icons.save_alt),
                        onPressed: () =>
                            _exportReport(title, data, format: 'pdf'),
                        tooltip: 'PDF olarak kaydet',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                        tooltip: 'Kapat',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metrics
                      if (data.containsKey('metrics')) ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    constraints.maxWidth > 600 ? 2 : 1,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: (data['metrics'] as List).length,
                              itemBuilder: (context, index) {
                                final metric = data['metrics'][index];
                                return Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          metric['title'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          metric['value'],
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (metric.containsKey('change')) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                metric['change'].startsWith('+')
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward,
                                                size: 16,
                                                color: metric['change']
                                                        .startsWith('+')
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  '${metric['change']} (${metric['period']})',
                                                  style: TextStyle(
                                                    color: metric['change']
                                                            .startsWith('+')
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Charts
                      if (data.containsKey('charts')) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Grafikler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...data['charts'].map((chart) {
                          switch (chart['type']) {
                            case 'line':
                              return _buildLineChart(chart);
                            case 'pie':
                              return _buildPieChart(chart);
                            case 'column':
                              return _buildColumnChart(chart);
                            default:
                              return const SizedBox.shrink();
                          }
                        }).toList(),
                        const SizedBox(height: 24),
                      ],

                      // Tables
                      if (data.containsKey('treatments')) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Tedavi Kayıtları',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              dataTextStyle: const TextStyle(
                                color: Colors.black87,
                              ),
                              columns: const [
                                DataColumn(label: Text('Tarih')),
                                DataColumn(label: Text('Hayvan No')),
                                DataColumn(label: Text('Durum')),
                                DataColumn(label: Text('Tedavi')),
                                DataColumn(label: Text('Veteriner')),
                              ],
                              rows:
                                  (data['treatments'] as List).map((treatment) {
                                return DataRow(cells: [
                                  DataCell(Text(DateFormat('dd.MM.yyyy')
                                      .format(treatment['date']))),
                                  DataCell(Text(treatment['animal'])),
                                  DataCell(Text(treatment['condition'])),
                                  DataCell(Text(treatment['treatment'])),
                                  DataCell(Text(treatment['vet'])),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(Map<String, dynamic> chart) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
        ),
        tooltipBehavior: TooltipBehavior(
            enable: true, format: 'Hayvan: {2}\nTarih: {0}\nAğırlık: {1}kg'),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enableDoubleTapZooming: true,
          enablePanning: true,
        ),
        series: <CartesianSeries>[
          LineSeries<TimeSeriesSales, DateTime>(
            name: chart['title'],
            dataSource: chart['data'],
            xValueMapper: (TimeSeriesSales sales, _) => sales.time,
            yValueMapper: (TimeSeriesSales sales, _) => sales.sales,
            dataLabelMapper: (TimeSeriesSales sales, _) => sales.animalName,
            legendItemText:
                '${chart['title']} - ${(chart['data'] as List<TimeSeriesSales>).first.animalName}',
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> chart) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.right,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CircularSeries>[
          PieSeries<ChartPieSegment, String>(
            dataSource: chart['data'],
            xValueMapper: (ChartPieSegment data, _) => data.segment,
            yValueMapper: (ChartPieSegment data, _) => data.size,
            pointColorMapper: (ChartPieSegment data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnChart(Map<String, dynamic> chart) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: chart['data'],
            xValueMapper: (Map<String, dynamic> data, _) =>
                data['category'] as String,
            yValueMapper: (Map<String, dynamic> data, _) =>
                data['value'] as num,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomReportDialog() {
    final selectedMetrics = <String>[].obs;
    final selectedCharts = <String>[].obs;
    final selectedTables = <String>[].obs;

    final availableMetrics = [
      'Toplam Hayvan Sayısı',
      'Aktif Hayvan Sayısı',
      'Hasta Hayvan Sayısı',
      'Gebe Hayvan Sayısı',
      'Günlük Süt Üretimi',
      'Aylık Süt Üretimi',
      'Yem Stoku',
      'Günlük Yem Tüketimi',
      'Toplam Gelir',
      'Toplam Gider',
    ];

    final availableCharts = [
      'Süt Verimi Trendi',
      'Sağlık Durumu Dağılımı',
      'Irk Dağılımı',
      'Gelir/Gider Trendi',
      'Yem Tüketim Trendi',
    ];

    final availableTables = [
      'Tedavi Kayıtları',
      'Gebelik Kayıtları',
      'Süt Kalitesi',
      'Gider Dağılımı',
      'Yem Envanteri',
    ];

    return AlertDialog(
      title: Row(
        children: [
          const Text('Özel Rapor Oluştur'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      content: Container(
        width: Get.width * 0.8,
        height: Get.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rapor Başlığı
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rapor Başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Metrikler
            const Text(
              'Metrikler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableMetrics.map((metric) {
                return Obx(() => FilterChip(
                      label: Text(metric),
                      selected: selectedMetrics.contains(metric),
                      onSelected: (selected) {
                        if (selected) {
                          selectedMetrics.add(metric);
                        } else {
                          selectedMetrics.remove(metric);
                        }
                      },
                    ));
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Grafikler
            const Text(
              'Grafikler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableCharts.map((chart) {
                return Obx(() => FilterChip(
                      label: Text(chart),
                      selected: selectedCharts.contains(chart),
                      onSelected: (selected) {
                        if (selected) {
                          selectedCharts.add(chart);
                        } else {
                          selectedCharts.remove(chart);
                        }
                      },
                    ));
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Tablolar
            const Text(
              'Tablolar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTables.map((table) {
                return Obx(() => FilterChip(
                      label: Text(table),
                      selected: selectedTables.contains(table),
                      onSelected: (selected) {
                        if (selected) {
                          selectedTables.add(table);
                        } else {
                          selectedTables.remove(table);
                        }
                      },
                    ));
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedMetrics.isEmpty &&
                selectedCharts.isEmpty &&
                selectedTables.isEmpty) {
              Get.snackbar(
                'Uyarı',
                'Lütfen en az bir öğe seçin',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            Get.back(result: {
              'metrics': selectedMetrics,
              'charts': selectedCharts,
              'tables': selectedTables,
            });
          },
          child: const Text('Oluştur'),
        ),
      ],
    );
  }

  Future<void> _printReport(String title, Map<String, dynamic> data) async {
    try {
      // TODO: Implement actual report printing
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Başarılı',
        'Rapor yazdırma işlemi başlatıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error printing report: $e');
      Get.snackbar(
        'Hata',
        'Rapor yazdırılırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _exportReport(String title, Map<String, dynamic> data,
      {String format = 'pdf'}) async {
    try {
      // TODO: Implement actual report export
      await Future.delayed(const Duration(seconds: 1));
      Get.back(); // Close preview dialog
      Get.snackbar(
        'Başarılı',
        'Rapor başarıyla ${format.toUpperCase()} olarak dışa aktarıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error exporting report: $e');
      Get.snackbar(
        'Hata',
        'Rapor dışa aktarılırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addHayvanToSuru(int suruId, Map<String, dynamic> hayvan) async {
    try {
      final suruIndex = suruListesi.indexWhere((suru) => suru['id'] == suruId);
      if (suruIndex != -1) {
        if (!suruListesi[suruIndex].containsKey('hayvanlar')) {
          suruListesi[suruIndex]['hayvanlar'] = [];
        }

        // Yeni hayvan ID'si oluştur
        final newId = (suruListesi[suruIndex]['hayvanlar'] as List).isEmpty
            ? 1
            : (suruListesi[suruIndex]['hayvanlar'] as List)
                    .map((h) => h['id'])
                    .reduce((max, id) => id > max ? id : max) +
                1;

        hayvan['id'] = newId;
        (suruListesi[suruIndex]['hayvanlar'] as List).add(hayvan);

        // Sürü istatistiklerini güncelle
        suruListesi[suruIndex]['hayvanSayisi']++;
        suruListesi[suruIndex]['aktifHayvanSayisi']++;

        // Listeyi güncelle
        suruListesi.refresh();
        _filterAndSortSuruler();

        Get.snackbar(
          'Başarılı',
          'Hayvan başarıyla sürüye eklendi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error adding hayvan to sürü: $e');
      Get.snackbar(
        'Hata',
        'Hayvan eklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
