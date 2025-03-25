import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/data_service.dart';
import 'adapter.dart';

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
  final String? ciftlikKupe;
  final String? ciftlikKupeRengi;
  final String? ulusalKupe;
  final String? ulusalKupeRengi;
  final double agirlik;
  final String durum;
  final bool gebelikDurumu;
  final bool damizlikDurumu;
  final int? damizlikPuan;
  final String? tipAdi;
  final String? suruAdi;
  final String? padokAdi;
  final String? dogumNumarasi;
  final int? kardesSayisi;
  final int? kuzuSayisi;
  final DateTime? edinmeTarihi;
  final String? edinmeYontemi;
  final DateTime? sonTohumlanmaTarihi;
  final DateTime? tahminiDogumTarihi;
  final String? notlar;
  final String? ekBilgi;
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
  // Yeni ağırlık ölçüm ortalama alanları
  final double? yediGunlukCanliAgirlikOrtalamasi;
  final double? onbesGunlukCanliAgirlikOrtalamasi;
  final double? otuzGunlukCanliAgirlikOrtalamasi;
  final double? gunlukCanliAgirlikArtisi;

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
    this.ciftlikKupe,
    this.ciftlikKupeRengi,
    this.ulusalKupe,
    this.ulusalKupeRengi,
    required this.agirlik,
    required this.durum,
    required this.gebelikDurumu,
    this.damizlikDurumu = false,
    this.damizlikPuan,
    this.tipAdi,
    this.suruAdi,
    this.padokAdi,
    this.dogumNumarasi,
    this.kardesSayisi,
    this.kuzuSayisi,
    this.edinmeTarihi,
    this.edinmeYontemi,
    this.sonTohumlanmaTarihi,
    this.tahminiDogumTarihi,
    this.notlar,
    this.ekBilgi,
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
    this.yediGunlukCanliAgirlikOrtalamasi,
    this.onbesGunlukCanliAgirlikOrtalamasi,
    this.otuzGunlukCanliAgirlikOrtalamasi,
    this.gunlukCanliAgirlikArtisi,
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
      'ciftlikKupe': ciftlikKupe,
      'ciftlikKupeRengi': ciftlikKupeRengi,
      'ulusalKupe': ulusalKupe,
      'ulusalKupeRengi': ulusalKupeRengi,
      'agirlik': agirlik,
      'durum': durum,
      'gebelikDurumu': gebelikDurumu,
      'damizlikDurumu': damizlikDurumu,
      'damizlikPuan': damizlikPuan,
      'tipAdi': tipAdi,
      'suruAdi': suruAdi,
      'padokAdi': padokAdi,
      'dogumNumarasi': dogumNumarasi,
      'kardesSayisi': kardesSayisi,
      'kuzuSayisi': kuzuSayisi,
      'edinmeTarihi': edinmeTarihi?.toIso8601String(),
      'edinmeYontemi': edinmeYontemi,
      'sonTohumlanmaTarihi': sonTohumlanmaTarihi?.toIso8601String(),
      'tahminiDogumTarihi': tahminiDogumTarihi?.toIso8601String(),
      'notlar': notlar,
      'ekBilgi': ekBilgi,
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
      'yediGunlukCanliAgirlikOrtalamasi': yediGunlukCanliAgirlikOrtalamasi,
      'onbesGunlukCanliAgirlikOrtalamasi': onbesGunlukCanliAgirlikOrtalamasi,
      'otuzGunlukCanliAgirlikOrtalamasi': otuzGunlukCanliAgirlikOrtalamasi,
      'gunlukCanliAgirlikArtisi': gunlukCanliAgirlikArtisi,
    };
  }
}

class HayvanController extends GetxController {
  // Bağımlılıklar
  final DataService _dataService = Get.find<DataService>();
  final SupabaseAdapter _supabaseAdapter = Get.find<SupabaseAdapter>();

  // Observable değişkenler
  var isLoading = false.obs;
  var hayvanListesi = RxList<Hayvan>();
  var filteredHayvanListesi = RxList<Hayvan>();
  var selectedHayvan = Rxn<Hayvan>();

  // Filtreleme değişkenleri
  var searchText = ''.obs;
  var selectedTur = 'Tümü'.obs;
  var selectedDurum = 'Tümü'.obs;
  var selectedIrk = 'Tümü'.obs;
  var selectedCinsiyet = 'Tümü'.obs;
  var selectedSaglikDurumu = 'Tümü'.obs;
  var showActive = true.obs;

  // Sıralama seçenekleri
  var sortBy = 'kupeNo'.obs;
  var sortAscending = true.obs;

  // Başlatma
  @override
  void onInit() {
    super.onInit();
    loadHayvanlar();
  }

  // Veritabanından hayvanları yükle
  Future<void> loadHayvanlar() async {
    isLoading.value = true;
    try {
      // Doğrudan adaptör üzerinden veri çek
      final results = await _supabaseAdapter.getHayvanlar();

      final List<Hayvan> loadedAnimals =
          results.map((data) => _mapToHayvan(data)).toList();

      hayvanListesi.assignAll(loadedAnimals);
      applyFilters(); // Aktif filtreleri uygula
    } catch (e) {
      print('Hayvanları yüklerken hata: $e');

      // Bir hata durumunda DataService üzerinden veri çek
      try {
        final results = await _dataService.fetchData(
          apiEndpoint: 'Animals',
          tableName: 'hayvanlar',
        );

        final List<Hayvan> loadedAnimals =
            results.map((data) => _mapToHayvan(data)).toList();

        hayvanListesi.assignAll(loadedAnimals);
        applyFilters(); // Aktif filtreleri uygula
      } catch (fallbackError) {
        print('Yedek yükleme de başarısız oldu: $fallbackError');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Veritabanı verisini Hayvan modeline dönüştür
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
      ciftlikKupe: data['ciftlik_kupe'],
      ciftlikKupeRengi: data['ciftlik_kupe_rengi'],
      ulusalKupe: data['ulusal_kupe'],
      ulusalKupeRengi: data['ulusal_kupe_rengi'],
      agirlik: data['agirlik'] != null
          ? double.parse(data['agirlik'].toString())
          : 0.0,
      durum: data['durum'] ?? 'Aktif',
      gebelikDurumu:
          data['gebelik_durumu'] == 1 || data['gebelik_durumu'] == true,
      damizlikDurumu:
          data['damizlik_durumu'] == 1 || data['damizlik_durumu'] == true,
      damizlikPuan: data['damizlik_puan'],
      tipAdi: data['tip_adi'],
      suruAdi: data['suru_adi'],
      padokAdi: data['padok_adi'],
      dogumNumarasi: data['dogum_numarasi'],
      kardesSayisi: data['kardes_sayisi'],
      kuzuSayisi: data['kuzu_sayisi'],
      edinmeTarihi: data['edinme_tarihi'] != null
          ? DateTime.parse(data['edinme_tarihi'])
          : null,
      edinmeYontemi: data['edinme_yontemi'],
      sonTohumlanmaTarihi: data['son_tohumlanma_tarihi'] != null
          ? DateTime.parse(data['son_tohumlanma_tarihi'])
          : null,
      tahminiDogumTarihi: data['tahmini_dogum_tarihi'] != null
          ? DateTime.parse(data['tahmini_dogum_tarihi'])
          : null,
      notlar: data['notlar'],
      ekBilgi: data['ek_bilgi'],
      aktif: data['aktif'] == 1 || data['aktif'] == true,
      saglikDurumu: data['saglik_durumu'] ?? 'Sağlıklı',
      gunlukSutUretimi: data['gunluk_sut_uretimi'] != null
          ? double.parse(data['gunluk_sut_uretimi'].toString())
          : 0.0,
      canliAgirlik: data['canli_agirlik'] != null
          ? double.parse(data['canli_agirlik'].toString())
          : 0.0,
      asiTakibi: [], // Bu alanlar ayrıca yüklenecek
      tedaviGecmisi: [],
      sutVerimi: [],
      sutBilesenleri: [],
      agirlikTakibi: [],
      kuruyaAyirmaTarihi: data['kuruya_ayirma_tarihi'] != null
          ? DateTime.parse(data['kuruya_ayirma_tarihi'])
          : null,
      kizginlikTakibi: [],
      yediGunlukCanliAgirlikOrtalamasi:
          data['yedi_gunluk_canli_agirlik_ortalamasi'],
      onbesGunlukCanliAgirlikOrtalamasi:
          data['onbes_gunluk_canli_agirlik_ortalamasi'],
      otuzGunlukCanliAgirlikOrtalamasi:
          data['otuz_gunluk_canli_agirlik_ortalamasi'],
      gunlukCanliAgirlikArtisi: data['gunluk_canli_agirlik_artisi'],
    );
  }

  // Tüm aktif filtreleri uygula
  void applyFilters() {
    List<Hayvan> tempList = List.from(hayvanListesi);

    // Aktif durum filtresi
    if (showActive.value) {
      tempList = tempList.where((hayvan) => hayvan.aktif).toList();
    }

    // Arama metni filtresi
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

    // Seçili hayvan türü filtresi
    if (selectedTur.value != 'Tümü') {
      tempList =
          tempList.where((hayvan) => hayvan.tur == selectedTur.value).toList();
    }

    // Seçili durum filtresi
    if (selectedDurum.value != 'Tümü') {
      tempList = tempList
          .where((hayvan) => hayvan.durum == selectedDurum.value)
          .toList();
    }

    // Seçili ırk filtresi
    if (selectedIrk.value != 'Tümü') {
      tempList =
          tempList.where((hayvan) => hayvan.irk == selectedIrk.value).toList();
    }

    // Seçili cinsiyet filtresi
    if (selectedCinsiyet.value != 'Tümü') {
      tempList = tempList
          .where((hayvan) => hayvan.cinsiyet == selectedCinsiyet.value)
          .toList();
    }

    // Seçili sağlık durumu filtresi
    if (selectedSaglikDurumu.value != 'Tümü') {
      tempList = tempList
          .where((hayvan) => hayvan.saglikDurumu == selectedSaglikDurumu.value)
          .toList();
    }

    // Sıralama uygula
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

  // Hayvan ekleme işlemi
  Future<bool> addHayvan(Map<String, dynamic> data) async {
    try {
      // Validate required fields
      if (!_validateHayvanData(data)) {
        Get.snackbar('Hata', 'Lütfen tüm zorunlu alanları doldurun');
        return false;
      }

      // Save to the database
      final result = await _dataService.saveData(
        apiEndpoint: 'hayvanlar',
        tableName: 'hayvanlar',
        data: data,
      );

      if (result) {
        Get.snackbar('Başarılı', 'Hayvan başarıyla eklendi');
        await refreshHayvanlar(); // Refresh data after adding
        return true;
      } else {
        Get.snackbar('Hata', 'Hayvan eklenirken bir sorun oluştu');
        return false;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Hayvan eklenirken bir hata oluştu: $e');
      return false;
    }
  }

  bool _validateHayvanData(Map<String, dynamic> data) {
    // At least one of RFID, farm tag, or national tag is required
    bool hasIdentifier =
        (data['rfid'] != null && data['rfid'].toString().isNotEmpty) ||
            (data['ciftlik_kupe'] != null &&
                data['ciftlik_kupe'].toString().isNotEmpty) ||
            (data['ulusal_kupe'] != null &&
                data['ulusal_kupe'].toString().isNotEmpty);

    // Validate other required fields
    return hasIdentifier &&
        data['tur'] != null &&
        data['irk'] != null &&
        data['cinsiyet'] != null &&
        data['dogum_tarihi'] != null;
  }

  // Refresh hayvan listesi
  Future<void> refreshHayvanlar() async {
    await loadHayvanlar();
  }

  // Gets the weight history for a specific animal
  Future<List<Map<String, dynamic>>> getHayvanTartimlar(String hayvanId) async {
    try {
      final result = await _dataService.getData(
        tableName: 'hayvan_tartimlar',
        where: 'hayvan_id = ?',
        whereArgs: [hayvanId],
      );

      if (result.isEmpty) {
        print('No weight records found for animal ID: $hayvanId');
      } else {
        print('Found ${result.length} weight records for animal ID: $hayvanId');
      }

      return result;
    } catch (e) {
      print('Error getting weight history: $e');
      return [];
    }
  }

  // Calculate weight averages and gains
  Future<Map<String, dynamic>> calculateWeightStatistics(
      String hayvanId) async {
    try {
      final weightData = await getHayvanTartimlar(hayvanId);
      if (weightData.isEmpty) {
        return {
          'yediGunlukCAO': null,
          'onbesGunlukCAO': null,
          'otuzGunlukCAO': null,
          'gunlukCAA': null,
        };
      }

      // Sort by date (newest first)
      weightData.sort(
          (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime));

      // Get today's date
      final now = DateTime.now();

      // Calculate 7-day average
      double yediGunlukCAO = _calculateAverageForDays(weightData, 7, now);

      // Calculate 15-day average
      double onbesGunlukCAO = _calculateAverageForDays(weightData, 15, now);

      // Calculate 30-day average
      double otuzGunlukCAO = _calculateAverageForDays(weightData, 30, now);

      // Calculate daily weight gain
      double? gunlukCAA = _calculateDailyWeightGain(weightData);

      return {
        'yediGunlukCAO': yediGunlukCAO > 0 ? yediGunlukCAO : null,
        'onbesGunlukCAO': onbesGunlukCAO > 0 ? onbesGunlukCAO : null,
        'otuzGunlukCAO': otuzGunlukCAO > 0 ? otuzGunlukCAO : null,
        'gunlukCAA': gunlukCAA,
      };
    } catch (e) {
      print('Error calculating weight statistics: $e');
      return {
        'yediGunlukCAO': null,
        'onbesGunlukCAO': null,
        'otuzGunlukCAO': null,
        'gunlukCAA': null,
      };
    }
  }

  double _calculateAverageForDays(
      List<Map<String, dynamic>> weightData, int days, DateTime currentDate) {
    List<double> weights = [];

    for (var record in weightData) {
      DateTime recordDate = record['tarih'] as DateTime;
      if (currentDate.difference(recordDate).inDays <= days) {
        weights.add(record['agirlik']);
      }
    }

    if (weights.isEmpty) return 0;
    return weights.reduce((a, b) => a + b) / weights.length;
  }

  double? _calculateDailyWeightGain(List<Map<String, dynamic>> weightData) {
    if (weightData.length < 2) return null;

    // Get the newest and oldest records
    var newest = weightData.first;
    var oldest = weightData.last;

    double weightDiff = newest['agirlik'] - oldest['agirlik'];
    int daysDiff = (newest['tarih'] as DateTime)
        .difference(oldest['tarih'] as DateTime)
        .inDays;

    if (daysDiff <= 0) return null;
    return weightDiff / daysDiff;
  }

  // Update weight statistics for an animal
  Future<bool> updateHayvanWeightStats(String hayvanId) async {
    try {
      final stats = await calculateWeightStatistics(hayvanId);

      // Update the animal record with new statistics
      final updateData = {
        'yedi_gunluk_canli_agirlik_ortalamasi': stats['yediGunlukCAO'],
        'onbes_gunluk_canli_agirlik_ortalamasi': stats['onbesGunlukCAO'],
        'otuz_gunluk_canli_agirlik_ortalamasi': stats['otuzGunlukCAO'],
        'gunluk_canli_agirlik_artisi': stats['gunlukCAA'],
      };

      final result = await _dataService.saveData(
        apiEndpoint: 'hayvanlar/$hayvanId',
        tableName: 'hayvanlar',
        data: updateData,
        isUpdate: true,
        primaryKeyField: 'id',
        primaryKeyValue: hayvanId,
      );

      if (result) {
        print('Updated weight statistics for animal ID: $hayvanId');
        await refreshHayvanlar(); // Refresh data after updating
      }

      return result;
    } catch (e) {
      print('Error updating weight statistics: $e');
      return false;
    }
  }

  // Hayvan güncelleme işlemi
  Future<bool> updateHayvan(int id, Map<String, dynamic> hayvanData) async {
    try {
      // Supabse üzerinden hayvan güncelleme
      await _supabaseAdapter.updateHayvan(id.toString(), hayvanData);

      // Yeni verileri almak için hayvan listesini güncelle
      await loadHayvanlar();

      // Supabase ile senkronize et
      final DataService dataService = Get.find<DataService>();
      if (dataService.isUsingSupabase) {
        await dataService
            .syncAfterUserInteraction(specificTables: ['hayvanlar']);
      }

      return true;
    } catch (e) {
      print('Hayvan güncelleme hatası: $e');
      return false;
    }
  }

  // Hayvan silme işlemi
  Future<bool> deleteHayvan(int id) async {
    try {
      // Supabse üzerinden hayvan silme
      final success = await _supabaseAdapter.deleteHayvan(id.toString());

      // Yeni verileri almak için hayvan listesini güncelle
      await loadHayvanlar();

      // Supabase ile senkronize et
      final DataService dataService = Get.find<DataService>();
      if (dataService.isUsingSupabase) {
        await dataService
            .syncAfterUserInteraction(specificTables: ['hayvanlar']);
      }

      return success;
    } catch (e) {
      print('Hayvan silme hatası: $e');
      return false;
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
