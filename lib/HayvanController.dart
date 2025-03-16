import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*
* HayvanController - Hayvan Yönetim Kontrolcüsü
* -------------------------------------------
* Bu kontrolcü sınıfı, uygulama genelinde hayvan verilerinin
* yönetiminden ve işlenmesinden sorumludur.
*
* Temel Özellikler:
* 1. Veri Yönetimi:
*    - Hayvan listesi (hayvanListesi)
*    - Seçili hayvan bilgileri (selectedHayvan)
*    - Filtreleme parametreleri
*    - Sıralama seçenekleri
*
* 2. CRUD İşlemleri:
*    - Hayvan ekleme (addHayvan)
*    - Hayvan güncelleme (updateHayvan)
*    - Hayvan silme (deleteHayvan)
*    - Hayvan sorgulama (getHayvan)
*
* 3. Filtreleme ve Arama:
*    - Türe göre filtreleme
*    - Yaşa göre filtreleme
*    - Duruma göre filtreleme
*    - Metin bazlı arama
*
* 4. İstatistik ve Raporlama:
*    - Hayvan sayıları
*    - Tür dağılımları
*    - Yaş dağılımları
*    - Sağlık durumu istatistikleri
*
* Önemli Metodlar:
* - initHayvanlar(): Başlangıç verilerini yükler
* - refreshData(): Verileri yeniler
* - filterHayvanlar(): Filtreleme uygular
* - sortHayvanlar(): Sıralama uygular
* - exportData(): Veri dışa aktarımı
*
* Bağımlılıklar:
* - AnimalService: Veritabanı işlemleri
* - NotificationService: Bildirim yönetimi
* - FileService: Dosya işlemleri
*/

class Hayvan {
  final int id;
  final String kupeNo;
  final String tur;
  final String irk;
  final String cinsiyet;
  final DateTime dogumTarihi;
  final String? anneKupeNo;
  final String? babaKupeNo;
  final String? chipNo;
  final String? rfid;
  final double agirlik;
  final String durum;
  final bool gebelikDurumu;
  final DateTime? sonTohumlanmaTarihi;
  final DateTime? tahminiDogumTarihi;
  final String? notlar;
  final bool aktif;
  final String saglikDurumu;
  final double gunlukSutUretimi;
  final double canliAgirlik;
  final List<Map<String, dynamic>> asiTakibi;
  final List<Map<String, dynamic>> tedaviGecmisi;
  final List<Map<String, dynamic>> sutVerimi;
  final List<Map<String, dynamic>> sutBilesenleri;
  final List<Map<String, dynamic>> agirlikTakibi;
  final DateTime? kuruyaAyirmaTarihi;
  final List<Map<String, dynamic>> kizginlikTakibi;

  Hayvan({
    required this.id,
    required this.kupeNo,
    required this.tur,
    required this.irk,
    required this.cinsiyet,
    required this.dogumTarihi,
    this.anneKupeNo,
    this.babaKupeNo,
    this.chipNo,
    this.rfid,
    required this.agirlik,
    required this.durum,
    required this.gebelikDurumu,
    this.sonTohumlanmaTarihi,
    this.tahminiDogumTarihi,
    this.notlar,
    this.aktif = true,
    required this.saglikDurumu,
    required this.gunlukSutUretimi,
    required this.canliAgirlik,
    required this.asiTakibi,
    required this.tedaviGecmisi,
    required this.sutVerimi,
    required this.sutBilesenleri,
    required this.agirlikTakibi,
    this.kuruyaAyirmaTarihi,
    required this.kizginlikTakibi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kupeNo': kupeNo,
      'tur': tur,
      'irk': irk,
      'cinsiyet': cinsiyet,
      'dogumTarihi': dogumTarihi.toIso8601String(),
      'anneKupeNo': anneKupeNo,
      'babaKupeNo': babaKupeNo,
      'chipNo': chipNo,
      'rfid': rfid,
      'agirlik': agirlik,
      'durum': durum,
      'gebelikDurumu': gebelikDurumu,
      'notlar': notlar,
      'aktif': aktif,
      'saglikDurumu': saglikDurumu,
      'gunlukSutUretimi': gunlukSutUretimi,
      'canliAgirlik': canliAgirlik,
      'asiTakibi': asiTakibi,
      'tedaviGecmisi': tedaviGecmisi,
      'sutVerimi': sutVerimi,
      'sutBilesenleri': sutBilesenleri,
      'agirlikTakibi': agirlikTakibi,
      'kizginlikTakibi': kizginlikTakibi,
    };
  }
}

class HayvanController extends GetxController {
  var hayvanListesi = <Hayvan>[].obs;
  var filteredHayvanListesi = <Hayvan>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'Tümü'.obs;
  var selectedSortOption = 'Küpe No (A-Z)'.obs;
  var viewType = 'list'.obs; // 'list' or 'grid'

  final filterOptions = [
    'Tümü',
    'Sağlıklı',
    'Hasta',
    'Karantina',
    'Gebe',
    'Kuru Dönem',
    'Laktasyon',
  ];

  final sortOptions = [
    'Küpe No (A-Z)',
    'Küpe No (Z-A)',
    'Yaş (Büyük-Küçük)',
    'Yaş (Küçük-Büyük)',
    'Süt Verimi (Yüksek-Düşük)',
    'Süt Verimi (Düşük-Yüksek)',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchHayvanlar();
  }

  Future<void> fetchHayvanlar() async {
    isLoading(true);
    try {
      // Gerçek veritabanı bağlantısı burada yapılacak
      // Örnek: hayvanListesi.value = await databaseHelper.getHayvanlar();
      await Future.delayed(const Duration(seconds: 1)); // Geçici bekleme
      hayvanListesi.value = [
        Hayvan(
          id: 1,
          kupeNo: 'TR-123456789',
          tur: 'İnek',
          irk: 'Holstein',
          cinsiyet: 'Dişi',
          dogumTarihi: DateTime.now().subtract(const Duration(days: 730)),
          anneKupeNo: 'TR-987654321',
          babaKupeNo: 'TR-456789123',
          chipNo: '1234567890',
          rfid: 'ABCD1234567890',
          agirlik: 650.5,
          durum: 'Sağlıklı',
          gebelikDurumu: true,
          sonTohumlanmaTarihi:
              DateTime.now().subtract(const Duration(days: 60)),
          tahminiDogumTarihi: DateTime.now().add(const Duration(days: 160)),
          notlar: 'Sağlıklı ve verimli bir inek.',
          aktif: true,
          saglikDurumu: 'Sağlıklı',
          gunlukSutUretimi: 28.5,
          canliAgirlik: 650.5,
          asiTakibi: [],
          tedaviGecmisi: [],
          sutVerimi: [],
          sutBilesenleri: [],
          agirlikTakibi: [],
          kizginlikTakibi: [],
        ),
        Hayvan(
          id: 2,
          kupeNo: 'TR-987654321',
          tur: 'İnek',
          irk: 'Simental',
          cinsiyet: 'Dişi',
          dogumTarihi: DateTime.now().subtract(const Duration(days: 1095)),
          chipNo: '0987654321',
          rfid: 'EFGH0987654321',
          agirlik: 720.0,
          durum: 'Hasta',
          gebelikDurumu: false,
          sonTohumlanmaTarihi:
              DateTime.now().subtract(const Duration(days: 60)),
          tahminiDogumTarihi: DateTime.now().add(const Duration(days: 160)),
          notlar: 'Hafif topallık var, tedavi devam ediyor.',
          aktif: true,
          saglikDurumu: 'Hasta',
          gunlukSutUretimi: 22.0,
          canliAgirlik: 720.0,
          asiTakibi: [],
          tedaviGecmisi: [],
          sutVerimi: [],
          sutBilesenleri: [],
          agirlikTakibi: [],
          kizginlikTakibi: [],
        ),
        Hayvan(
          id: 3,
          kupeNo: 'TR-456789123',
          tur: 'Boğa',
          irk: 'Holstein',
          cinsiyet: 'Erkek',
          dogumTarihi: DateTime.now().subtract(const Duration(days: 1460)),
          chipNo: '4567891230',
          rfid: 'IJKL4567891230',
          agirlik: 950.0,
          durum: 'Sağlıklı',
          gebelikDurumu: false,
          sonTohumlanmaTarihi: null,
          tahminiDogumTarihi: null,
          notlar: 'Damızlık boğa.',
          aktif: true,
          saglikDurumu: 'Sağlıklı',
          gunlukSutUretimi: 0.0,
          canliAgirlik: 950.0,
          asiTakibi: [],
          tedaviGecmisi: [],
          sutVerimi: [],
          sutBilesenleri: [],
          agirlikTakibi: [],
          kizginlikTakibi: [],
        ),
      ];
      _filterAndSortHayvanlar();
    } catch (e) {
      print('Error fetching hayvanlar: $e');
      Get.snackbar('Hata', 'Hayvan verileri yüklenirken bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void _filterAndSortHayvanlar() {
    var filtered = List<Hayvan>.from(hayvanListesi);

    // Apply filters
    if (selectedFilter.value != 'Tümü') {
      filtered = filtered.where((hayvan) {
        switch (selectedFilter.value) {
          case 'Sağlıklı':
          case 'Hasta':
          case 'Karantina':
            return hayvan.saglikDurumu == selectedFilter.value;
          case 'Gebe':
            return hayvan.gebelikDurumu;
          case 'Kuru Dönem':
            return hayvan.gunlukSutUretimi == 0;
          case 'Laktasyon':
            return hayvan.gunlukSutUretimi > 0;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((hayvan) {
        return hayvan.kupeNo.toLowerCase().contains(query) ||
            hayvan.irk.toLowerCase().contains(query) ||
            hayvan.saglikDurumu.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (selectedSortOption.value) {
      case 'Küpe No (A-Z)':
        filtered.sort((a, b) => a.kupeNo.compareTo(b.kupeNo));
        break;
      case 'Küpe No (Z-A)':
        filtered.sort((a, b) => b.kupeNo.compareTo(a.kupeNo));
        break;
      case 'Yaş (Büyük-Küçük)':
        filtered.sort((a, b) => b.dogumTarihi.compareTo(a.dogumTarihi));
        break;
      case 'Yaş (Küçük-Büyük)':
        filtered.sort((a, b) => a.dogumTarihi.compareTo(b.dogumTarihi));
        break;
      case 'Süt Verimi (Yüksek-Düşük)':
        filtered
            .sort((a, b) => b.gunlukSutUretimi.compareTo(a.gunlukSutUretimi));
        break;
      case 'Süt Verimi (Düşük-Yüksek)':
        filtered
            .sort((a, b) => a.gunlukSutUretimi.compareTo(b.gunlukSutUretimi));
        break;
    }

    filteredHayvanListesi.value = filtered;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _filterAndSortHayvanlar();
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    _filterAndSortHayvanlar();
  }

  void updateSortOption(String option) {
    selectedSortOption.value = option;
    _filterAndSortHayvanlar();
  }

  void toggleViewType() {
    viewType.value = viewType.value == 'list' ? 'grid' : 'list';
  }

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();

    if (years > 0) {
      return '$years yıl ${months > 0 ? '$months ay' : ''}';
    } else if (months > 0) {
      return '$months ay';
    } else {
      return '${difference.inDays} gün';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Sağlıklı':
        return Colors.green;
      case 'Hasta':
        return Colors.red;
      case 'Karantina':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
