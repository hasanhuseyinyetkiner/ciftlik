import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../services/database_service.dart';
import '../services/data_service.dart';
import 'package:share_plus/share_plus.dart';

class WeightAnalysisController extends GetxController {
  DatabaseService? _dbService;
  final DataService _dataService = Get.find<DataService>();
  final _dbConnected = false.obs;

  // Track sync status
  final isSyncing = false.obs;
  final lastSyncTime = Rxn<DateTime>();

  final isLoading = true.obs;
  final selectedPeriod = 30.obs;
  final selectedGroup = 'Tüm Gruplar'.obs;
  final minWeight = 0.0.obs;
  final maxWeight = 0.0.obs;

  final weightData = <Map<String, dynamic>>[].obs;
  final chartData = <FlSpot>[].obs;
  final performanceMetrics = {
    'ortalama_artis': 0.0,
    'en_yuksek_artis': 0.0,
    'en_dusuk_artis': 0.0,
    'hedef_basari': 0.0
  }.obs;

  final targetWeight = 0.0.obs;
  final targetDate = DateTime.now().obs;

  final averageGain = 0.0.obs;
  final totalGain = 0.0.obs;
  final highestGain = 0.0.obs;
  final lowestGain = 0.0.obs;

  final groups = <String>['Tüm Gruplar'].obs;

  bool get dbConnected => _dbConnected.value;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      _dbService = Get.find<DatabaseService>();
      _dbConnected.value = true;
    } catch (e) {
      _dbConnected.value = false;
      print('Database service not available: $e');
    }

    // Force sync before fetching data if Supabase is available
    if (_dataService.isUsingSupabase) {
      await syncWeightData();
    }

    fetchData();
  }

  // Sync weight data with Supabase
  Future<bool> syncWeightData() async {
    if (!_dataService.isUsingSupabase) return false;

    isSyncing.value = true;

    try {
      final success = await _dataService.syncAfterUserInteraction(
        specificTables: ['tartim', 'agirlik_olcum'],
      );

      if (success) {
        lastSyncTime.value = DateTime.now();
        print('Weight analysis data synced with Supabase');
      }

      return success;
    } catch (e) {
      print('Error syncing weight analysis data: $e');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // Export data to Supabase
  Future<bool> exportToSupabase() async {
    if (!_dataService.isUsingSupabase) {
      Get.snackbar(
        'Senkronizasyon Hatası',
        'Supabase bağlantısı aktif değil. Çevrimdışı moddasınız.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isSyncing.value = true;

    try {
      // First ensure local data is up to date
      await fetchData();

      // For each weight record, ensure it's in Supabase
      for (final record in weightData) {
        // Skip if already in Supabase (would need a flag for this)
        // For now, we'll try to save each record
        await _dataService.saveData(
          apiEndpoint: 'WeightMeasurements',
          tableName: 'tartim',
          data: record,
        );
      }

      // Sync all data
      final success = await syncWeightData();

      if (success) {
        Get.snackbar(
          'Başarılı',
          'Ağırlık verileri Supabase\'e aktarıldı',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      print('Error exporting to Supabase: $e');
      Get.snackbar(
        'Hata',
        'Veriler Supabase\'e aktarılırken hata oluştu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      if (_dbConnected.value && _dbService != null) {
        weightData.value = await _dbService!.getWeightAnalysisData(
          selectedPeriod.value,
          selectedGroup.value,
          minWeight.value,
          maxWeight.value,
        );
      } else {
        // Eğer veritabanı bağlantısında sorun varsa örnek veri oluştur
        weightData.value = _getMockData();
      }

      updatePerformanceMetrics();
    } catch (e) {
      print('Error fetching weight data: $e');
      // Hata durumunda da örnek veri kullan
      weightData.value = _getMockData();
      updatePerformanceMetrics();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _getMockData() {
    // Örnek ağırlık verisi oluştur
    final today = DateTime.now();
    List<Map<String, dynamic>> mockData = [];

    for (int i = 0; i < 10; i++) {
      final date = today.subtract(Duration(days: i * 3));
      final baseWeight = 350.0 + (10 - i) * 2.5; // Ağırlık zamanla artıyor
      final randomVariation = (DateTime.now().millisecondsSinceEpoch % 10) / 10;

      mockData.add({
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'weight': baseWeight + randomVariation,
        'animal_id': 1001,
        'name': 'Demo Hayvan',
        'group_name': 'Demo Grup',
        'gain': i > 0 ? 2.5 + randomVariation : 0.0,
        'totalGain': (10 - i) * 2.5,
      });
    }

    return mockData;
  }

  void updatePerformanceMetrics() {
    if (weightData.isEmpty) {
      averageGain.value = 0;
      totalGain.value = 0;
      highestGain.value = 0;
      lowestGain.value = 0;
      return;
    }

    List<double> gains = [];
    double totalGainValue = 0;

    for (var data in weightData) {
      if (data['gain'] != null && data['gain'] is double && data['gain'] > 0) {
        gains.add(data['gain']);
        totalGainValue += data['gain'];
      }
    }

    if (gains.isNotEmpty) {
      totalGain.value = totalGainValue;
      averageGain.value = totalGainValue / gains.length;
      gains.sort();
      lowestGain.value = gains.first;
      highestGain.value = gains.last;
    } else {
      averageGain.value = 0;
      totalGain.value = 0;
      highestGain.value = 0;
      lowestGain.value = 0;
    }
  }

  void updateFilters({int? period, String? group, double? min, double? max}) {
    if (period != null) selectedPeriod.value = period;
    if (group != null) selectedGroup.value = group;
    if (min != null) minWeight.value = min;
    if (max != null) maxWeight.value = max;
    fetchData();
  }

  void setTarget(double weight, DateTime date) {
    targetWeight.value = weight;
    targetDate.value = date;
    _processData(); // Hedef başarı oranını güncelle
  }

  Future<void> shareReport() async {
    try {
      isLoading.value = true;

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/agirlik_analizi.txt');

      // Rapor içeriğini hazırla
      final content = '''
Ağırlık Analizi Raporu
Tarih: ${DateTime.now()}
Grup: ${selectedGroup.value}
Dönem: ${selectedPeriod.value} gün

Performans Metrikleri:
- Ortalama Artış: ${performanceMetrics['ortalama_artis']?.toStringAsFixed(2)} kg
- En Yüksek Artış: ${performanceMetrics['en_yuksek_artis']?.toStringAsFixed(2)} kg
- En Düşük Artış: ${performanceMetrics['en_dusuk_artis']?.toStringAsFixed(2)} kg

Hedef Bilgileri:
- Hedef Ağırlık: ${targetWeight.value} kg
- Hedef Tarihi: ${targetDate.value}
- Başarı Oranı: ${performanceMetrics['hedef_basari']?.toStringAsFixed(2)}%

Detaylı Veriler:
${weightData.map((data) => '${data['date']}: ${data['weight']} kg (Artış: ${data['gain'] ?? 0} kg)').join('\n')}
''';

      // Dosyaya yaz
      await file.writeAsString(content);

      // Paylaş
      await Share.shareXFiles([XFile(file.path)],
          text: 'Ağırlık Analizi Raporu');
    } catch (e) {
      Get.snackbar('Hata', 'Rapor paylaşılırken bir hata oluştu: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _processData() {
    if (weightData.isEmpty) return;

    // Verileri tarihe göre sırala
    weightData.sort((a, b) => (a['date'] as String).compareTo(b['date']));

    // Hedef başarı oranını hesapla
    if (targetWeight.value > 0 && weightData.isNotEmpty) {
      final currentWeight = weightData.last['weight'] as double;
      final progress = (currentWeight / targetWeight.value) * 100;
      performanceMetrics['hedef_basari'] = progress > 100 ? 100 : progress;
    }
  }

  void changePeriod(int days) {
    selectedPeriod.value = days;
    fetchData();
  }

  void changeGroup(String group) {
    selectedGroup.value = group;
    fetchData();
  }

  void changeWeightRange(double min, double max) {
    minWeight.value = min;
    maxWeight.value = max;
    fetchData();
  }
}
