import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart'; // Add import for DataService
import '../HayvanController.dart';
import 'package:flutter/material.dart'; // Add import for Colors

/*
* WeightController - Tartım Kontrolcüsü
* ------------------------------
* Bu kontrolcü sınıfı, tartım işlemlerinin yönetimi ve
* veri işlemlerinden sorumludur.
*
* Temel İşlevler:
* 1. Veri Yönetimi:
*    - Tartım kayıtları
*    - Veri doğrulama
*    - CRUD işlemleri
*    - Veri senkronizasyonu
*
* 2. İş Mantığı:
*    - Ağırlık hesaplamaları
*    - Trend analizi
*    - Hedef takibi
*    - Performans analizi
*
* 3. Durum Yönetimi:
*    - Yükleme durumu
*    - Hata yönetimi
*    - Filtreleme durumu
*    - Sayfalama durumu
*
* 4. Veri İşleme:
*    - İstatistik hesaplama
*    - Veri filtreleme
*    - Sıralama
*    - Gruplama
*
* 5. Entegrasyonlar:
*    - Veritabanı servisi
*    - Bluetooth servisi
*    - Senkronizasyon
*    - Bildirim sistemi
*
* Özellikler:
* - GetX state management
* - Reactive programlama
* - Dependency injection
* - Error handling
*
* Servisler:
* - DatabaseService
* - BluetoothService
* - SyncService
* - NotificationService
*/

class WeightController extends GetxController {
  // Supabase sync service
  final DataService _dataService = Get.find<DataService>();

  // Sync tracking
  final RxBool isSyncing = false.obs;
  final Rxn<DateTime> lastSyncTime = Rxn<DateTime>();

  // Tartım kayıtları
  final RxList<Map<String, dynamic>> tartimKayitlari =
      <Map<String, dynamic>>[].obs;

  // Seçili hayvan
  final Rxn<String> selectedAnimal = Rxn<String>();

  // Tarih aralığı filtreleri
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Sıralama seçenekleri
  final RxBool isAscending = true.obs;

  // Bluetooth bağlantı durumu
  final RxBool isBluetoothConnected = false.obs;
  final RxBool isBluetoothLoading = false.obs;

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

    // Sync data if online
    if (_dataService.isUsingSupabase) {
      syncWithSupabase();
    }
  }

  void _loadInitialData() {
    fetchTartimKayitlari();
    fetchHayvanlar();
  }

  Future<void> fetchTartimKayitlari() async {
    try {
      final filter = _buildFilter();
      final List<String> conditions = [];
      final List<dynamic> args = [];

      if (selectedAnimal.value != null) {
        conditions.add('hayvan_id = ?');
        args.add(selectedAnimal.value);
      }

      if (startDate.value != null) {
        conditions.add('tarih >= ?');
        args.add(DateFormat('yyyy-MM-dd').format(startDate.value!));
      }

      if (endDate.value != null) {
        conditions.add('tarih <= ?');
        args.add(DateFormat('yyyy-MM-dd').format(endDate.value!));
      }

      final result = await _dataService.getData(
        tableName: 'hayvan_tartimlar',
        where: conditions.isEmpty ? null : conditions.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
      );

      if (result.isNotEmpty) {
        // Convert string dates to DateTime objects
        final processedResult = result.map((record) {
          if (record['tarih'] is String) {
            record['tarih'] = DateTime.parse(record['tarih']);
          }
          return record;
        }).toList();

        tartimKayitlari.assignAll(processedResult);
        print('Loaded ${tartimKayitlari.length} weight records');
      } else {
        tartimKayitlari.clear();
        print('No weight records found');
      }
    } catch (e) {
      tartimKayitlari.clear();
      print('Error fetching weight records: $e');
      Get.snackbar(
        'Hata',
        'Tartım kayıtları yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _buildFilter() {
    List<String> conditions = [];

    if (selectedAnimal.value != null) {
      conditions.add('hayvan_id=${selectedAnimal.value}');
    }

    if (startDate.value != null) {
      conditions.add(
          "tarih >= '${DateFormat('yyyy-MM-dd').format(startDate.value!)}'");
    }

    if (endDate.value != null) {
      conditions
          .add("tarih <= '${DateFormat('yyyy-MM-dd').format(endDate.value!)}'");
    }

    return conditions.join(' AND ');
  }

  Future<void> fetchHayvanlar() async {
    try {
      final result = await _dataService.getData(
        tableName: 'hayvanlar',
      );

      if (result.isNotEmpty) {
        final List<Map<String, dynamic>> processedHayvanlar =
            result.map((animal) {
          return {
            'id': animal['id'].toString(),
            'ad': animal['kupe_no'] ?? 'Bilinmeyen',
            'tur': animal['tur'] ?? 'Bilinmeyen',
          };
        }).toList();

        hayvanlar.assignAll(processedHayvanlar);
        print('Loaded ${hayvanlar.length} animals');
      }
    } catch (e) {
      print('Error fetching animals: $e');
    }
  }

  // Save new weight record
  Future<bool> saveTartim(Map<String, dynamic> tartimData) async {
    try {
      final result = await _dataService.saveData(
        apiEndpoint: 'hayvan_tartimlar',
        tableName: 'hayvan_tartimlar',
        data: tartimData,
      );

      if (result) {
        // Update animal's latest weight
        await _updateHayvanLatestWeight(
          tartimData['hayvan_id'].toString(),
          tartimData['agirlik'],
        );

        // Refresh the list
        await fetchTartimKayitlari();

        // Sync with Supabase if online
        if (_dataService.isUsingSupabase) {
          syncWithSupabase();
        }

        return true;
      }

      return false;
    } catch (e) {
      print('Error saving weight record: $e');
      Get.snackbar(
        'Hata',
        'Tartım kaydedilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update animal's latest weight
  Future<void> _updateHayvanLatestWeight(String hayvanId, double weight) async {
    try {
      await _dataService.saveData(
        apiEndpoint: 'hayvanlar/$hayvanId',
        tableName: 'hayvanlar',
        data: {'canli_agirlik': weight},
        isUpdate: true,
        primaryKeyField: 'id',
        primaryKeyValue: hayvanId,
      );

      // Also update weight statistics
      final hayvanController = Get.find<HayvanController>();
      await hayvanController.updateHayvanWeightStats(hayvanId);
    } catch (e) {
      print('Error updating animal weight: $e');
    }
  }

  // Delete weight record
  Future<bool> deleteTartim(String tartimId) async {
    try {
      final result = await _dataService.deleteData(
        apiEndpoint: 'hayvan_tartimlar/$tartimId',
        tableName: 'hayvan_tartimlar',
        id: tartimId,
      );

      if (result) {
        await fetchTartimKayitlari();

        // Sync with Supabase if online
        if (_dataService.isUsingSupabase) {
          syncWithSupabase();
        }

        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting weight record: $e');
      Get.snackbar(
        'Hata',
        'Tartım silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Sync with Supabase
  Future<void> syncWithSupabase() async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = true;

      await _dataService
          .syncData(specificTables: ['hayvan_tartimlar', 'hayvanlar']);

      lastSyncTime.value = DateTime.now();

      // Refresh data after sync
      await fetchTartimKayitlari();
    } catch (e) {
      print('Error syncing with Supabase: $e');
      Get.snackbar(
        'Senkronizasyon Hatası',
        'Veriler senkronize edilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  // Filter records by date range
  void filterByDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    fetchTartimKayitlari();
  }

  // Filter records by animal
  void filterByAnimal(String? animalId) {
    selectedAnimal.value = animalId;
    fetchTartimKayitlari();
  }

  // Clear all filters
  void clearFilters() {
    selectedAnimal.value = null;
    startDate.value = null;
    endDate.value = null;
    fetchTartimKayitlari();
  }

  // Get formatted date
  String getFormattedDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Calculate weight change percentage
  double calculateWeightChange(double currentWeight, double previousWeight) {
    if (previousWeight == 0) return 0;
    return ((currentWeight - previousWeight) / previousWeight) * 100;
  }

  // Get weight change color
  Color getWeightChangeColor(double change) {
    if (change > 0) {
      return Colors.green;
    } else if (change < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  // Get previous weight for an animal
  double? getPreviousWeight(String hayvanId, DateTime currentDate) {
    final previousRecords = tartimKayitlari
        .where((record) =>
            record['hayvan_id'] == hayvanId &&
            (record['tarih'] as DateTime).isBefore(currentDate))
        .toList();

    if (previousRecords.isEmpty) return null;

    // Sort by date (newest first)
    previousRecords.sort(
        (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime));

    return previousRecords.first['agirlik'];
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
