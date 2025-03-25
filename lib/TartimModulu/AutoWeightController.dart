import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as BluetoothPlus;
import '../services/database_service.dart';
import '../services/data_service.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';

class AutoWeightController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  final DataService _dataService = Get.find<DataService>();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  late NotificationService _notificationService;

  // Bluetooth connection variables
  final isScanning = false.obs;
  final isConnected = false.obs;
  final deviceName = ''.obs;
  final deviceStatus = 'Bağlı değil'.obs;
  final signalStrength = 0.obs;
  final connectionQuality = 'Yok'.obs;

  // Weighing variables
  final currentWeight = 0.0.obs;
  final isWeighing = false.obs;
  final isWeightStable = false.obs;
  final statusMessage = 'Hazır'.obs;
  final stabilizationProgress = 0.0.obs;
  final weightData = <Map<String, dynamic>>[].obs;

  // Sync variables
  final isDataSynced = true.obs;

  // Weight separation rules
  final separationRules = <Map<String, dynamic>>[
    {
      'name': 'Yetişkin Büyükbaş',
      'minWeight': 400.0,
      'maxWeight': 800.0,
      'category': 'Yetişkin'
    },
    {
      'name': 'Genç Büyükbaş',
      'minWeight': 200.0,
      'maxWeight': 399.9,
      'category': 'Genç'
    },
    {
      'name': 'Buzağı',
      'minWeight': 50.0,
      'maxWeight': 199.9,
      'category': 'Yavru'
    },
    {
      'name': 'Yetişkin Koyun',
      'minWeight': 40.0,
      'maxWeight': 120.0,
      'category': 'Koyun'
    },
    {'name': 'Kuzu', 'minWeight': 10.0, 'maxWeight': 39.9, 'category': 'Kuzu'},
  ].obs;

  // Statistics
  final stats = {
    'totalWeighings': 0,
    'successfulWeighings': 0,
    'errorRate': 0.0,
    'averageWeight': 0.0,
    'lastSync': DateTime.now(),
  }.obs as Rx<Map<String, dynamic>>;

  // Device info
  BluetoothPlus.BluetoothDevice? _device;
  List<BluetoothPlus.BluetoothService>? _services;
  BluetoothPlus.BluetoothCharacteristic? _weightCharacteristic;

  // Timer for simulation
  Timer? _simulationTimer;
  Timer? _stabilityTimer;

  // Readings buffer for stability detection
  final List<double> _recentReadings = [];
  final int _stabilityBufferSize = 5;
  final double _stabilityThreshold = 0.3;

  @override
  void onInit() {
    super.onInit();
    _initializeDatabase();
    _loadSampleData();

    if (Get.isRegistered<NotificationService>()) {
      _notificationService = Get.find<NotificationService>();
    }
  }

  @override
  void onClose() {
    stopWeighing();
    disconnect();
    super.onClose();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _db.init();
      // Load weight data from local database
      final List<Map<String, dynamic>> data = await _db.query(
          'SELECT * FROM weight_measurements ORDER BY timestamp DESC LIMIT 50');

      if (data.isNotEmpty) {
        weightData.assignAll(data);
        await _loadStats();
      }
    } catch (e) {
      print('Error initializing database: $e');
      _loadSampleData();
    }
  }

  Future<void> _loadStats() async {
    try {
      // Get stats from local database
      final totalCountResult =
          await _db.query('SELECT COUNT(*) as count FROM weight_measurements');
      final successfulCountResult = await _db.query(
          'SELECT COUNT(*) as count FROM weight_measurements WHERE isStable = 1');

      final averageResult = await _db
          .query('SELECT AVG(weight) as average FROM weight_measurements');

      final lastSyncResult = await _db
          .query('SELECT * FROM sync_log ORDER BY timestamp DESC LIMIT 1');

      final totalCount = totalCountResult.isNotEmpty
          ? (totalCountResult.first['count'] as int? ?? 0)
          : 0;
      final successfulCount = successfulCountResult.isNotEmpty
          ? (successfulCountResult.first['count'] as int? ?? 0)
          : 0;

      final newStats = stats.value.map((key, value) {
        if (key == 'totalWeighings') return MapEntry(key, totalCount);
        if (key == 'successfulWeighings') return MapEntry(key, successfulCount);
        if (key == 'errorRate') {
          return MapEntry(
              key,
              totalCount > 0
                  ? ((totalCount - successfulCount) / totalCount) * 100
                  : 0.0);
        }
        if (key == 'averageWeight') {
          return MapEntry(
              key,
              averageResult.isNotEmpty && averageResult.first['average'] != null
                  ? (averageResult.first['average'] as num).toDouble()
                  : 0.0);
        }
        if (key == 'lastSync' && lastSyncResult.isNotEmpty) {
          return MapEntry(
              key, DateTime.parse(lastSyncResult.first['timestamp'] as String));
        }
        return MapEntry(key, value);
      });

      stats.value = newStats;

      // Check sync status
      final unsyncedCountResult = await _db.query(
          'SELECT COUNT(*) as count FROM weight_measurements WHERE synced = 0');

      final unsyncedCount = unsyncedCountResult.isNotEmpty
          ? (unsyncedCountResult.first['count'] as int? ?? 0)
          : 0;
      isDataSynced.value = unsyncedCount == 0;
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  void _loadSampleData() {
    // Add sample data for demonstration
    weightData.assignAll([
      {
        'id': 1,
        'weight': 120.5,
        'timestamp':
            DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
        'isStable': true,
        'category': 'Yetişkin',
        'synced': 1,
      },
      {
        'id': 2,
        'weight': 85.2,
        'timestamp':
            DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'isStable': true,
        'category': 'Genç',
        'synced': 1,
      },
      {
        'id': 3,
        'weight': 45.7,
        'timestamp':
            DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        'isStable': false,
        'category': 'Yavru',
        'synced': 0,
      },
    ]);

    stats.value = {
      'totalWeighings': 10,
      'successfulWeighings': 8,
      'errorRate': 20.0,
      'averageWeight': 78.5,
      'lastSync': DateTime.now().subtract(Duration(hours: 3)),
    };
  }

  Future<void> startScanning() async {
    try {
      isScanning.value = true;
      deviceStatus.value = 'Cihaz aranıyor...';

      // Simulasyon için bir timer başlat
      Future.delayed(Duration(seconds: 3), () {
        // Rastgele bir cihaz bağlantısı simüle et
        if (!isConnected.value) {
          final random = Random().nextInt(100);

          if (random > 30) {
            // %70 başarı oranı
            deviceName.value = 'BT Scale ${Random().nextInt(1000)}';
            deviceStatus.value = 'Bağlantı kuruldu';
            signalStrength.value = 60 + Random().nextInt(40); // 60-99 arası
            isConnected.value = true;
            _updateConnectionQuality();
          } else {
            deviceStatus.value = 'Cihaz bulunamadı';
          }

          isScanning.value = false;
        }
      });
    } catch (e) {
      print('Cihaz arama hatası: $e');
      deviceStatus.value = 'Cihaz arama hatası: $e';
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(String deviceId) async {
    try {
      deviceStatus.value = 'Bağlanıyor...';

      // Directly create a device from the ID
      try {
        _device = BluetoothPlus.BluetoothDevice.fromId(deviceId);
      } catch (e) {
        print('Error creating device from ID: $e');
        // Fallback to simulation mode
        _simulateDeviceConnection();
        return;
      }

      if (_device == null) {
        print('Device not found');
        _simulateDeviceConnection();
        return;
      }

      // Connect to the device
      await _device!.connect();

      deviceName.value = _device!.name;
      deviceStatus.value = 'Bağlandı';
      isConnected.value = true;

      // Update signal strength
      signalStrength.value = 85;
      connectionQuality.value = 'İyi';

      // Discover services
      _services = await _device!.discoverServices();

      // Find the weight characteristic
      for (BluetoothPlus.BluetoothService service in _services!) {
        for (BluetoothPlus.BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify ||
              characteristic.properties.read) {
            _weightCharacteristic = characteristic;

            // Subscribe to weight notifications
            await _weightCharacteristic!.setNotifyValue(true);
            _weightCharacteristic!.value.listen((value) {
              if (value.isNotEmpty) {
                // Simple parsing assuming the first byte is the weight in kg
                final weightValue = value[0].toDouble();
                processWeightReading(weightValue);
              }
            });

            break;
          }
        }
        if (_weightCharacteristic != null) break;
      }

      // If no characteristic found, use simulation
      if (_weightCharacteristic == null) {
        _startWeightSimulation();
      }
    } catch (e) {
      print('Error connecting to device: $e');
      deviceStatus.value = 'Bağlantı hatası: $e';

      // Simulate for demonstration
      _simulateDeviceConnection();
    }
  }

  void _simulateDeviceConnection() {
    deviceName.value = 'Sim-Scale BT';
    deviceStatus.value = 'Simülasyon Modu';
    isConnected.value = true;
    signalStrength.value = 75;
    connectionQuality.value = 'Simülasyon';

    _startWeightSimulation();
  }

  void _startWeightSimulation() {
    // Start a timer that simulates weight changes
    _simulationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!isConnected.value) {
        timer.cancel();
        return;
      }

      // Simulate weight fluctuations
      final baseWeight = 85.0;
      final fluctuation = isWeighing.value ? 0.5 : 3.0;
      final newWeight = baseWeight +
          (fluctuation *
              (2 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000 - 1));

      // Process the simulated reading
      processWeightReading(newWeight);
    });
  }

  void processWeightReading(double weight) {
    currentWeight.value = weight;

    // Add to recent readings for stability detection
    _recentReadings.add(weight);
    if (_recentReadings.length > _stabilityBufferSize) {
      _recentReadings.removeAt(0);
    }

    // Calculate stability
    if (_recentReadings.length >= _stabilityBufferSize) {
      final mean =
          _recentReadings.reduce((a, b) => a + b) / _recentReadings.length;
      final deviations = _recentReadings.map((w) => (w - mean).abs()).toList();
      final maxDeviation = deviations.reduce((a, b) => a > b ? a : b);

      // Update stability progress (inverse of deviation)
      stabilizationProgress.value = 1.0 - (maxDeviation / 5.0).clamp(0.0, 1.0);

      isWeightStable.value = maxDeviation < _stabilityThreshold;
      statusMessage.value = isWeightStable.value
          ? 'Kararlı ölçüm'
          : 'Ölçüm kararlı hale geliyor...';

      // If stable and weighing, save the measurement after a short delay
      if (isWeighing.value && isWeightStable.value) {
        if (_stabilityTimer == null || !_stabilityTimer!.isActive) {
          _stabilityTimer = Timer(Duration(seconds: 2), () {
            if (isWeightStable.value && isWeighing.value) {
              saveWeightMeasurement(weight, true);
              statusMessage.value = 'Ölçüm kaydedildi';

              // Auto-stop weighing after measurement
              stopWeighing();
            }
          });
        }
      } else if (_stabilityTimer != null && _stabilityTimer!.isActive) {
        _stabilityTimer!.cancel();
      }
    }
  }

  void disconnect() {
    if (_simulationTimer != null) {
      _simulationTimer!.cancel();
      _simulationTimer = null;
    }

    if (_stabilityTimer != null) {
      _stabilityTimer!.cancel();
      _stabilityTimer = null;
    }

    if (_device != null && isConnected.value) {
      _device!.disconnect();
    }

    _device = null;
    _services = null;
    _weightCharacteristic = null;

    isConnected.value = false;
    deviceName.value = '';
    deviceStatus.value = 'Bağlı değil';
    signalStrength.value = 0;
    connectionQuality.value = 'Yok';

    // Ensure weighing is stopped
    isWeighing.value = false;
    isWeightStable.value = false;
    statusMessage.value = 'Hazır';

    // Sync any unsaved data
    syncWeightData();
  }

  void toggleWeighing() {
    if (isWeighing.value) {
      stopWeighing();
    } else {
      startWeighing();
    }
  }

  void startWeighing() {
    if (!isConnected.value) return;

    isWeighing.value = true;
    statusMessage.value = 'Ölçüm yapılıyor...';
    _recentReadings.clear();
  }

  void stopWeighing() {
    isWeighing.value = false;
    statusMessage.value = 'Ölçüm durduruldu';

    if (_stabilityTimer != null && _stabilityTimer!.isActive) {
      _stabilityTimer!.cancel();
    }
  }

  Future<void> saveWeightMeasurement(double weight, bool isStable) async {
    try {
      final now = DateTime.now();
      final category = determineCategory(weight);

      final measurement = {
        'weight': weight,
        'timestamp': now.toIso8601String(),
        'isStable': isStable ? 1 : 0,
        'category': category,
        'synced': 0,
      };

      // Add to the local list
      weightData.insert(0, measurement);

      // Save to local database
      try {
        await _db.execute(
          'INSERT INTO weight_measurements (weight, timestamp, isStable, category, synced) VALUES (@weight, @timestamp, @isStable, @category, @synced)',
          substitutionValues: measurement,
        );
      } catch (dbError) {
        print('Error saving to database: $dbError');
      }

      // Show notification
      if (Get.isRegistered<NotificationService>()) {
        _notificationService.showWeightNotification(weight, isStable);
      }

      // Try to sync if online
      if (_connectivityService.isConnected) {
        await syncWeightData();
      }

      // Update statistics
      await updateStatsAfterMeasurement();
    } catch (e) {
      print('Error saving weight measurement: $e');
    }
  }

  String determineCategory(double weight) {
    if (weight > 100) {
      return 'Yetişkin';
    } else if (weight > 70) {
      return 'Genç';
    } else if (weight > 40) {
      return 'Yavru';
    } else {
      return 'Diğer';
    }
  }

  Future<void> syncWeightData() async {
    if (!_connectivityService.isConnected) {
      Get.snackbar(
        'Bağlantı Hatası',
        'Verileri senkronize etmek için internet bağlantınızı kontrol edin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Get unsynchronized records
      final unsyncedData = await _db.query(
        'SELECT * FROM weight_measurements WHERE synced = 0',
      );

      if (unsyncedData.isEmpty) {
        isDataSynced.value = true;
        return;
      }

      // Sync each record
      int syncedCount = 0;
      for (final record in unsyncedData) {
        try {
          // Try to send to Supabase
          await _dataService.saveData(
            apiEndpoint: 'weight_measurements',
            tableName: 'weight_measurements',
            data: record,
          );

          // Update synced status locally
          try {
            await _db.execute(
              'UPDATE weight_measurements SET synced = 1 WHERE id = @id',
              substitutionValues: {'id': record['id']},
            );
            syncedCount++;
          } catch (updateError) {
            print('Error updating sync status: $updateError');
          }
        } catch (e) {
          print('Error syncing record ${record['id']}: $e');
        }
      }

      // Update sync log
      try {
        await _db.execute(
          'INSERT INTO sync_log (timestamp, records_synced) VALUES (@timestamp, @records_synced)',
          substitutionValues: {
            'timestamp': DateTime.now().toIso8601String(),
            'records_synced': syncedCount,
          },
        );
      } catch (logError) {
        print('Error updating sync log: $logError');
      }

      // Check if all records synced
      final remainingUnsyncedResult = await _db.query(
        'SELECT COUNT(*) as count FROM weight_measurements WHERE synced = 0',
      );

      final remainingUnsynced = remainingUnsyncedResult.isNotEmpty
          ? (remainingUnsyncedResult.first['count'] as int? ?? 0)
          : 0;

      isDataSynced.value = remainingUnsynced == 0;

      // Update stats
      final newStats = Map<String, dynamic>.from(stats.value);
      newStats['lastSync'] = DateTime.now();
      stats.value = newStats;

      Get.snackbar(
        'Senkronizasyon Başarılı',
        '$syncedCount kayıt senkronize edildi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error syncing weight data: $e');
      Get.snackbar(
        'Senkronizasyon Hatası',
        'Veriler senkronize edilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Stats üzerindeki güncellemeler için tipli dönüşüm
  Future<void> updateStatsAfterMeasurement() async {
    try {
      // Tip dönüşüm hatasını önlemek için önce Map<String, dynamic> oluştur
      final currentStats = Map<String, dynamic>.from(stats.value);

      // Son senkronizasyon zamanını güncelle
      currentStats['lastSync'] = DateTime.now();

      // Şimdi stats.value'ya geri atamak için Map<String, Object> olarak oluştur
      // İçeriğini manuel olarak kopyala
      final newStats = <String, Object>{};
      currentStats.forEach((key, value) {
        // null kontrolü
        if (value != null) {
          newStats[key] = value;
        } else {
          // null değerleri varsayılanlarla doldur
          if (key == 'totalWeighings' || key == 'successfulWeighings') {
            newStats[key] = 0;
          } else if (key == 'errorRate' || key == 'averageWeight') {
            newStats[key] = 0.0;
          } else {
            newStats[key] = '';
          }
        }
      });

      // Şimdi Map<String, Object> olarak atayabiliriz
      stats.value = newStats;

      Get.snackbar(
        'Senkronizasyon Başarılı',
        'Ölçüm verileri buluta aktarıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Stats güncelleme hatası: $e');
    }
  }

  // Stats üzerindeki güncellemeler için tipli dönüşüm - bu fonksiyon updateStatistics yerine geçer
  Future<void> refreshStatistics() async {
    try {
      // Tip dönüşüm hatasını önlemek için önce Map<String, dynamic> oluştur
      final currentStats = Map<String, dynamic>.from(stats.value);

      // İstatistikleri güncelle
      currentStats['totalWeighings'] = await _getWeightMeasurementCount();
      currentStats['successfulWeighings'] =
          await _getStableWeightMeasurementCount();

      // Hata oranını hesapla ve güncelle
      final totalMeasurements = currentStats['totalWeighings'] as int;
      final successfulMeasurements = currentStats['successfulWeighings'] as int;

      currentStats['errorRate'] = totalMeasurements > 0
          ? ((totalMeasurements - successfulMeasurements) / totalMeasurements) *
              100
          : 0.0;

      // Ortalama ağırlığı güncelle
      final averageWeight = await _getAverageWeight();
      currentStats['averageWeight'] = averageWeight ?? 0.0;

      // Şimdi stats.value'ya geri atamak için Map<String, Object> olarak oluştur
      // İçeriğini manuel olarak kopyala
      final newStats = <String, Object>{};
      currentStats.forEach((key, value) {
        // null kontrolü
        if (value != null) {
          newStats[key] = value;
        } else {
          // null değerleri varsayılanlarla doldur
          if (key == 'totalWeighings' || key == 'successfulWeighings') {
            newStats[key] = 0;
          } else if (key == 'errorRate' || key == 'averageWeight') {
            newStats[key] = 0.0;
          } else {
            newStats[key] = '';
          }
        }
      });

      // Şimdi Map<String, Object> olarak atayabiliriz
      stats.value = newStats;
    } catch (e) {
      print('Error updating stats: $e');
    }
  }

  // Helper methods for statistics
  Future<int> _getWeightMeasurementCount() async {
    return await _db.getWeightMeasurementCount();
  }

  Future<int> _getStableWeightMeasurementCount() async {
    return await _db.getStableWeightMeasurementCount();
  }

  Future<double?> _getAverageWeight() async {
    return await _db.getAverageWeight();
  }

  // Bağlantı kalitesini güncelle
  void _updateConnectionQuality() {
    if (!isConnected.value) {
      connectionQuality.value = 'Yok';
      return;
    }

    if (signalStrength.value >= 80) {
      connectionQuality.value = 'Mükemmel';
    } else if (signalStrength.value >= 60) {
      connectionQuality.value = 'İyi';
    } else if (signalStrength.value >= 40) {
      connectionQuality.value = 'Orta';
    } else if (signalStrength.value >= 20) {
      connectionQuality.value = 'Zayıf';
    } else {
      connectionQuality.value = 'Çok Zayıf';
    }
  }
}
