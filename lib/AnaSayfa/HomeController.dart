import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/DatabaseService.dart';
import '../services/api_service.dart';
import 'dart:async';

/*
* HomeController - Ana Sayfa Kontrolcüsü
* ---------------------------------
* Bu kontrolcü sınıfı, ana sayfanın durum yönetimini ve
* iş mantığını kontrol eder.
*
* Temel Sorumluluklar:
* 1. Sayfa Durumu:
*    - Aktif sekme kontrolü
*    - Yükleme durumu
*    - Hata yönetimi
*    - Yenileme kontrolü
*
* 2. Veri Yönetimi:
*    - İstatistik verileri
*    - Bildirimler
*    - Kullanıcı tercihleri
*    - Cache yönetimi
*
* 3. Navigasyon:
*    - Sayfa geçişleri
*    - Modal yönetimi
*    - Geri tuşu kontrolü
*    - Derin bağlantılar
*
* 4. İş Mantığı:
*    - Veri filtreleme
*    - Veri sıralama
*    - Hesaplamalar
*    - Optimizasyonlar
*
* Özellikler:
* - GetX state management
* - Reactive programlama
* - Dependency injection
* - Lifecycle yönetimi
*
* Bağımlılıklar:
* - AuthService
* - DatabaseService
* - ApiService
* - CacheService
*/

class HomeController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final ApiService _apiService = Get.find<ApiService>();

  // Observable states
  var isSearching = false.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Module states
  var isSyncingData = false.obs;
  var lastSyncTime = Rx<DateTime?>(null);

  // Hayvan sayıları
  var totalAnimals = 0.obs;
  var activeAnimals = 0.obs;
  var pregnantAnimals = 0.obs;
  var sickAnimals = 0.obs;

  // Bildirimler
  var unreadNotifications = 0.obs;
  var urgentNotifications = 0.obs;

  // Modüller için aktif/pasif durumlar
  final Map<String, RxBool> moduleStatus = {
    'health': true.obs,
    'milk': true.obs,
    'weight': true.obs,
    'feed': true.obs,
    'finances': true.obs,
    'pregnancy': true.obs,
    'reports': true.obs,
    'settings': true.obs,
  };

  // Ana sayfa verileri
  final RxInt animalCount = 0.obs;
  final RxDouble dailyMilk = 0.0.obs;
  final RxInt alertCount = 0.obs;
  final RxInt pendingVaccines = 0.obs;

  // Grafik verileri
  final RxList<FlSpot> weeklyMilkData = <FlSpot>[].obs;

  // Etkinlik verileri
  final RxList<Map<String, dynamic>> upcomingEvents =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeServices();
    // Periyodik senkronizasyon
    Timer.periodic(const Duration(minutes: 15), (timer) {
      syncData();
    });
    fetchInitialData();
  }

  Future<void> initializeServices() async {
    try {
      isLoading(true);
      await _databaseService.init();
      await loadDashboardData();
      await syncData();
      isLoading(false);
    } catch (e) {
      hasError(true);
      errorMessage(e.toString());
      isLoading(false);
    }
  }

  Future<void> loadDashboardData() async {
    try {
      final db = await _databaseService.database;

      // Toplam aktif hayvan sayısı
      final totalResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM hayvanlar WHERE silindi = 0');
      totalAnimals(Rx(totalResult.first['count'] as int));

      // Aktif hayvan sayısı
      final activeResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM hayvanlar WHERE durum = "aktif" AND silindi = 0');
      activeAnimals(Rx(activeResult.first['count'] as int));

      // Gebe hayvan sayısı
      final pregnantResult = await db.rawQuery('''
        SELECT COUNT(DISTINCT hayvan_id) as count FROM gebelik_kontrolleri 
        WHERE durum = "gebe" AND silindi = 0
      ''');
      pregnantAnimals(Rx(pregnantResult.first['count'] as int));

      // Hasta hayvan sayısı
      final sickResult = await db.rawQuery('''
        SELECT COUNT(DISTINCT hayvan_id) as count FROM saglik_kayitlari 
        WHERE tani IS NOT NULL AND silindi = 0
        AND muayene_tarihi >= date('now', '-30 days')
      ''');
      sickAnimals(Rx(sickResult.first['count'] as int));

      // Okunmamış bildirim sayısı
      final notifResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM bildirimler WHERE okundu = 0 AND silindi = 0');
      unreadNotifications(Rx(notifResult.first['count'] as int));

      // Acil bildirim sayısı
      final urgentResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM bildirimler WHERE okundu = 0 AND tip = "acil" AND silindi = 0');
      urgentNotifications(Rx(urgentResult.first['count'] as int));
    } catch (e) {
      hasError(true);
      errorMessage('Gösterge paneli verileri yüklenirken hata: $e');
    }
  }

  Future<void> syncData() async {
    if (isSyncingData.value) return; // Zaten senkronizasyon yapılıyorsa çık

    try {
      isSyncingData(true);

      // Hayvan verileri
      try {
        final animalData = await _apiService.getHayvanlar();
        await _databaseService.syncAnimalData(animalData);
      } catch (e) {
        print('Hayvan verileri senkronize edilirken hata: $e');
      }

      // Sağlık kayıtları
      try {
        final healthData = await _apiService.getSaglikKayitlari();
        await _databaseService.syncHealthRecords(healthData);
      } catch (e) {
        print('Sağlık kayıtları senkronize edilirken hata: $e');
      }

      // Süt ölçümleri
      try {
        final milkData = await _apiService.getSutOlcumleri();
        await _databaseService.syncMilkData(milkData);
      } catch (e) {
        print('Süt ölçümleri senkronize edilirken hata: $e');
      }

      // Aşı kayıtları
      try {
        final vaccineData = await _apiService.getAsiKayitlari();
        await _databaseService.syncVaccineData(vaccineData);
      } catch (e) {
        print('Aşı kayıtları senkronize edilirken hata: $e');
      }

      // Finansal kayıtlar
      try {
        final financeData = await _apiService.getGelirGider();
        await _databaseService.syncFinanceData(financeData);
      } catch (e) {
        print('Finansal kayıtlar senkronize edilirken hata: $e');
      }

      // Tartım kayıtları
      try {
        final weightData = await _apiService.getTartimKayitlari();
        await syncTartimKayitlari(weightData);
      } catch (e) {
        print('Tartım kayıtları senkronize edilirken hata: $e');
      }

      // Gebelik kontrolleri
      try {
        final pregnancyData = await _apiService.getGebelikKontrolleri();
        await syncGebelikKontrolleri(pregnancyData);
      } catch (e) {
        print('Gebelik kayıtları senkronize edilirken hata: $e');
      }

      // Yem kayıtları
      try {
        final feedData = await _apiService.getYemKayitlari();
        await syncYemKayitlari(feedData);
      } catch (e) {
        print('Yem kayıtları senkronize edilirken hata: $e');
      }

      // Su tüketim kayıtları
      try {
        final waterData = await _apiService.getSuTuketimKayitlari();
        await syncSuTuketimKayitlari(waterData);
      } catch (e) {
        print('Su tüketim kayıtları senkronize edilirken hata: $e');
      }

      // Bildirimler
      try {
        final notificationData = await _apiService.getBildirimler();
        await syncBildirimler(notificationData);
      } catch (e) {
        print('Bildirimler senkronize edilirken hata: $e');
      }

      // Senkronizasyon tarihini ve paneli güncelle
      lastSyncTime(DateTime.now());
      await loadDashboardData();
      isSyncingData(false);
    } catch (e) {
      hasError(true);
      errorMessage('Veri senkronizasyonu sırasında hata: $e');
      isSyncingData(false);
    }
  }

  Future<void> addAnimalType(
      Map<String, dynamic> animalData, BuildContext context) async {
    try {
      isLoading(true);
      await _databaseService.addAnimalType(animalData, context);
      await _apiService.createHayvan(animalData);
      isLoading(false);
    } catch (e) {
      hasError(true);
      errorMessage('Hayvan tipi eklenirken hata: $e');
      isLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> getAnimalTypes() async {
    try {
      return await _databaseService.getAnimalTypesFromSQLite();
    } catch (e) {
      hasError(true);
      errorMessage('Hayvan tipleri alınırken hata: $e');
      return [];
    }
  }

  void clearSearch() {
    isSearching(false);
  }

  Future<void> refreshData() async {
    try {
      isLoading(true);
      await syncData();
      isLoading(false);
    } catch (e) {
      hasError(true);
      errorMessage('Veriler yenilenirken hata: $e');
      isLoading(false);
    }
  }

  void clearError() {
    hasError(false);
    errorMessage('');
  }

  Future<void> syncTartimKayitlari(Map<String, dynamic> data) async {
    // Implementation of syncTartimKayitlari method
  }

  Future<void> syncGebelikKontrolleri(Map<String, dynamic> data) async {
    // Implementation of syncGebelikKontrolleri method
  }

  Future<void> syncYemKayitlari(Map<String> data) async {
    // Implementation of syncYemKayitlari method
  }

  Future<void> syncSuTuketimKayitlari(Map<String, dynamic> data) async {
    // Implementation of syncSuTuketimKayitlari method
  }

  Future<void> syncBildirimler(Map<String, dynamic> data) async {
    // Implementation of syncBildirimler method
  }

  /// Ana sayfa verilerini yükler
  Future<void> fetchInitialData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      // Toplam hayvan sayısını al
      await _fetchAnimalCount();

      // Günlük süt miktarını al
      await _fetchDailyMilk();

      // Aktif uyarıları al
      await _fetchAlerts();

      // Planlanan aşıları al
      await _fetchPendingVaccines();

      // Haftalık süt grafiği verilerini al
      await _fetchWeeklyMilkData();

      // Yaklaşan etkinlikleri al
      await _fetchUpcomingEvents();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Veriler yüklenirken bir hata oluştu: $e';
      print('Veri yükleme hatası: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Hayvan sayısını getirir
  Future<void> _fetchAnimalCount() async {
    try {
      // Gerçek uygulamada veritabanından alınacaktır
      animalCount.value = 124;
    } catch (e) {
      print('Hayvan sayısı yükleme hatası: $e');
    }
  }

  /// Günlük süt miktarını getirir
  Future<void> _fetchDailyMilk() async {
    try {
      // Gerçek uygulamada veritabanından alınacaktır
      dailyMilk.value = 256.5;
    } catch (e) {
      print('Süt miktarı yükleme hatası: $e');
    }
  }

  /// Aktif uyarıları getirir
  Future<void> _fetchAlerts() async {
    try {
      // Gerçek uygulamada veritabanından alınacaktır
      alertCount.value = 5;
    } catch (e) {
      print('Uyarı yükleme hatası: $e');
    }
  }

  /// Planlanan aşıları getirir
  Future<void> _fetchPendingVaccines() async {
    try {
      // Gerçek uygulamada veritabanından alınacaktır
      pendingVaccines.value = 8;
    } catch (e) {
      print('Aşı planı yükleme hatası: $e');
    }
  }

  /// Haftalık süt verileri grafiğini getirir
  Future<void> _fetchWeeklyMilkData() async {
    try {
      // Gerçek uygulamada veritabanından alınacaktır
      // Örnek veri oluşturma
      weeklyMilkData.value = [
        FlSpot(0, 235), // Pazartesi
        FlSpot(1, 248), // Salı
        FlSpot(2, 240), // Çarşamba
        FlSpot(3, 255), // Perşembe
        FlSpot(4, 260), // Cuma
        FlSpot(5, 252), // Cumartesi
        FlSpot(6, 245), // Pazar
      ];
    } catch (e) {
      print('Süt grafiği yükleme hatası: $e');
    }
  }

  /// Yaklaşan etkinlikleri getirir
  Future<void> _fetchUpcomingEvents() async {
    try {
      // Gerçek uygulamada veritabanından alınacaktır
      upcomingEvents.value = [
        {
          'title': 'Sürü Aşılaması',
          'date': '21 Haziran 2023',
          'type': 'vaccine'
        },
        {
          'title': 'Gebelik Kontrolü',
          'date': '23 Haziran 2023',
          'type': 'checkup'
        },
        {
          'title': 'Tohumlama Programı',
          'date': '28 Haziran 2023',
          'type': 'insemination'
        },
        {'title': 'Doğum Takibi', 'date': '30 Haziran 2023', 'type': 'birth'},
      ];
    } catch (e) {
      print('Etkinlik yükleme hatası: $e');
    }
  }
}
