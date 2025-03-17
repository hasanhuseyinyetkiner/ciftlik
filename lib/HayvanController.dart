import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/data_service.dart';

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
* - DataService: Veritabanı ve API işlemleri
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
  // DataService dependency injection
  final DataService _dataService = Get.find<DataService>();

  // Observable variables
  var isLoading = false.obs;
  var hayvanListesi = RxList<Hayvan>();
  var filteredHayvanListesi = RxList<Hayvan>();
  var selectedHayvan = Rxn<Hayvan>();

  // Filter variables
  var searchText = ''.obs;
  var selectedTur = 'Tümü'.obs;
  var selectedDurum = 'Tümü'.obs;
  var selectedIrk = 'Tümü'.obs;
  var selectedCinsiyet = 'Tümü'.obs;
  var selectedSaglikDurumu = 'Tümü'.obs;
  var showActive = true.obs;

  // Sort options
  var sortBy = 'kupeNo'.obs;
  var sortAscending = true.obs;

  // Initialization
  @override
  void onInit() {
    super.onInit();
    loadHayvanlar();
  }

  // Load animals from database/API
  Future<void> loadHayvanlar() async {
    isLoading.value = true;
    try {
      final results = await _dataService.fetchData(
        apiEndpoint: 'Animals',
        tableName: 'hayvanlar',
      );

      final List<Hayvan> loadedAnimals =
          results.map((data) => _mapToHayvan(data)).toList();

      hayvanListesi.assignAll(loadedAnimals);
      applyFilters(); // Apply any active filters
    } catch (e) {
      print('Error loading animals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Convert database data to Hayvan model
  Hayvan _mapToHayvan(Map<String, dynamic> data) {
    return Hayvan(
      id: data['id'] ?? 0,
      kupeNo: data['kupe_no'] ?? '',
      tur: data['tur'] ?? '',
      irk: data['irk'] ?? '',
      cinsiyet: data['cinsiyet'] ?? '',
      dogumTarihi: data['dogum_tarihi'] != null
          ? DateTime.parse(data['dogum_tarihi'])
          : DateTime.now(),
      anneKupeNo: data['anne_kupe_no'],
      babaKupeNo: data['baba_kupe_no'],
      chipNo: data['chip_no'],
      rfid: data['rfid'],
      agirlik: data['agirlik'] != null
          ? double.parse(data['agirlik'].toString())
          : 0.0,
      durum: data['durum'] ?? 'Aktif',
      gebelikDurumu:
          data['gebelik_durumu'] == 1 || data['gebelik_durumu'] == true,
      sonTohumlanmaTarihi: data['son_tohumlanma_tarihi'] != null
          ? DateTime.parse(data['son_tohumlanma_tarihi'])
          : null,
      tahminiDogumTarihi: data['tahmini_dogum_tarihi'] != null
          ? DateTime.parse(data['tahmini_dogum_tarihi'])
          : null,
      notlar: data['notlar'],
      aktif: data['aktif'] == 1 || data['aktif'] == true,
      saglikDurumu: data['saglik_durumu'] ?? 'Sağlıklı',
      gunlukSutUretimi: data['gunluk_sut_uretimi'] != null
          ? double.parse(data['gunluk_sut_uretimi'].toString())
          : 0.0,
      canliAgirlik: data['canli_agirlik'] != null
          ? double.parse(data['canli_agirlik'].toString())
          : 0.0,
      // Additional fields will be loaded separately when needed
      asiTakibi: [],
      tedaviGecmisi: [],
      sutVerimi: [],
      sutBilesenleri: [],
      agirlikTakibi: [],
      kuruyaAyirmaTarihi: data['kuruya_ayirma_tarihi'] != null
          ? DateTime.parse(data['kuruya_ayirma_tarihi'])
          : null,
      kizginlikTakibi: [],
    );
  }

  // Apply all active filters
  void applyFilters() {
    List<Hayvan> tempList = List.from(hayvanListesi);

    // Filter by active status
    if (showActive.value) {
      tempList = tempList.where((hayvan) => hayvan.aktif).toList();
    }

    // Filter by search text
    if (searchText.value.isNotEmpty) {
      tempList = tempList.where((hayvan) {
        return hayvan.kupeNo
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            hayvan.chipNo
                    ?.toLowerCase()
                    .contains(searchText.value.toLowerCase()) ==
                true ||
            hayvan.rfid
                    ?.toLowerCase()
                    .contains(searchText.value.toLowerCase()) ==
                true;
      }).toList();
    }

    // Filter by selected animal type
    if (selectedTur.value != 'Tümü') {
      tempList =
          tempList.where((hayvan) => hayvan.tur == selectedTur.value).toList();
    }

    // Filter by selected status
    if (selectedDurum.value != 'Tümü') {
      tempList = tempList
          .where((hayvan) => hayvan.durum == selectedDurum.value)
          .toList();
    }

    // Filter by selected breed
    if (selectedIrk.value != 'Tümü') {
      tempList =
          tempList.where((hayvan) => hayvan.irk == selectedIrk.value).toList();
    }

    // Filter by selected gender
    if (selectedCinsiyet.value != 'Tümü') {
      tempList = tempList
          .where((hayvan) => hayvan.cinsiyet == selectedCinsiyet.value)
          .toList();
    }

    // Filter by selected health status
    if (selectedSaglikDurumu.value != 'Tümü') {
      tempList = tempList
          .where((hayvan) => hayvan.saglikDurumu == selectedSaglikDurumu.value)
          .toList();
    }

    // Apply sorting
    tempList.sort((a, b) {
      var aValue, bValue;

      switch (sortBy.value) {
        case 'kupeNo':
          aValue = a.kupeNo;
          bValue = b.kupeNo;
          break;
        case 'tur':
          aValue = a.tur;
          bValue = b.tur;
          break;
        case 'dogumTarihi':
          aValue = a.dogumTarihi;
          bValue = b.dogumTarihi;
          break;
        case 'agirlik':
          aValue = a.agirlik;
          bValue = b.agirlik;
          break;
        default:
          aValue = a.kupeNo;
          bValue = b.kupeNo;
      }

      int comparison;
      if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = 0;
      }

      return sortAscending.value ? comparison : -comparison;
    });

    filteredHayvanListesi.assignAll(tempList);
  }

  // Add new animal
  Future<bool> addHayvan(Map<String, dynamic> hayvanData) async {
    isLoading.value = true;
    try {
      final success = await _dataService.saveData(
        apiEndpoint: 'Animals',
        tableName: 'hayvanlar',
        data: hayvanData,
      );

      if (success) {
        await loadHayvanlar(); // Reload the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding animal: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update existing animal
  Future<bool> updateHayvan(int id, Map<String, dynamic> hayvanData) async {
    isLoading.value = true;
    try {
      final success = await _dataService.saveData(
        apiEndpoint: 'Animals/$id',
        tableName: 'hayvanlar',
        data: hayvanData,
        isUpdate: true,
        primaryKeyField: 'id',
      );

      if (success) {
        await loadHayvanlar(); // Reload the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating animal: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete animal
  Future<bool> deleteHayvan(int id) async {
    isLoading.value = true;
    try {
      final success = await _dataService.deleteData(
        apiEndpoint: 'Animals',
        tableName: 'hayvanlar',
        primaryKeyField: 'id',
        primaryKeyValue: id,
      );

      if (success) {
        await loadHayvanlar(); // Reload the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting animal: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set sorting options
  void setSorting(String field, {bool? ascending}) {
    if (sortBy.value == field) {
      // Toggle direction if clicking the same field
      sortAscending.value = ascending ?? !sortAscending.value;
    } else {
      // New field, default to ascending
      sortBy.value = field;
      sortAscending.value = ascending ?? true;
    }
    applyFilters(); // Re-apply filters with new sorting
  }

  // Set search text
  void setSearchText(String text) {
    searchText.value = text;
    applyFilters();
  }

  // Set filter values
  void setFilter(String filterType, String value) {
    switch (filterType) {
      case 'tur':
        selectedTur.value = value;
        break;
      case 'durum':
        selectedDurum.value = value;
        break;
      case 'irk':
        selectedIrk.value = value;
        break;
      case 'cinsiyet':
        selectedCinsiyet.value = value;
        break;
      case 'saglikDurumu':
        selectedSaglikDurumu.value = value;
        break;
    }
    applyFilters();
  }

  // Toggle active filter
  void toggleActiveFilter(bool value) {
    showActive.value = value;
    applyFilters();
  }

  // Get unique values for filters
  List<String> getUniqueValues(String field) {
    final Set<String> values = {'Tümü'};

    switch (field) {
      case 'tur':
        hayvanListesi.forEach((hayvan) => values.add(hayvan.tur));
        break;
      case 'durum':
        hayvanListesi.forEach((hayvan) => values.add(hayvan.durum));
        break;
      case 'irk':
        hayvanListesi.forEach((hayvan) => values.add(hayvan.irk));
        break;
      case 'cinsiyet':
        hayvanListesi.forEach((hayvan) => values.add(hayvan.cinsiyet));
        break;
      case 'saglikDurumu':
        hayvanListesi.forEach((hayvan) => values.add(hayvan.saglikDurumu));
        break;
    }

    return values.toList()..sort();
  }
}
