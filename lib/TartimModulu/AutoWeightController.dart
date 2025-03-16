import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/database_service.dart';

class AutoWeightController extends GetxController {
  DatabaseService? _db;
  final _dbConnected = false.obs;

  // Cihaz bağlantı durumu
  final isConnected = false.obs;
  final isScanning = false.obs;
  final deviceName = ''.obs;
  final deviceStatus = 'Bağlı Değil'.obs;

  // Tartım verileri
  final weightData = <Map<String, dynamic>>[].obs;
  final currentWeight = 0.0.obs;
  final isWeighing = false.obs;

  // İstatistikler
  final stats = <String, Object>{
    'totalWeighings': 0,
    'errorRate': 0.0,
    'lastSync': DateTime.now(),
  }.obs;

  // Ayırma kuralları
  final separationRules = <Map<String, dynamic>>[].obs;

  // Bluetooth cihazı
  BluetoothDevice? connectedDevice;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
    initBluetooth();
  }

  Future<void> _initDatabase() async {
    try {
      _db = Get.find<DatabaseService>();
      _dbConnected.value = true;
      loadSeparationRules();
      loadStats();
    } catch (e) {
      _dbConnected.value = false;
      print('Database service not available: $e');
      // Load sample data instead
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    // Sample separation rules
    separationRules.assignAll([
      {
        'id': 1,
        'name': 'Küçük Hayvanlar',
        'minWeight': 0.0,
        'maxWeight': 300.0,
        'category': 'A',
      },
      {
        'id': 2,
        'name': 'Orta Boyutlu Hayvanlar',
        'minWeight': 300.1,
        'maxWeight': 600.0,
        'category': 'B',
      },
      {
        'id': 3,
        'name': 'Büyük Hayvanlar',
        'minWeight': 600.1,
        'maxWeight': 1000.0,
        'category': 'C',
      },
    ]);

    // Sample stats
    stats.value = {
      'totalWeighings': 5,
      'errorRate': 0.0,
      'lastSync': DateTime.now(),
    };
  }

  // Bluetooth başlatma
  Future<void> initBluetooth() async {
    try {
      // Bluetooth'un açık olup olmadığını kontrol et
      // if (!await FlutterBluePlus.instance.isBluetoothEnabled) {
      //   Get.snackbar('Hata', 'Bluetooth desteklenmiyor.');
      //   return;
      // }
      String? lastDeviceId;

      if (_dbConnected.value && _db != null) {
        try {
          lastDeviceId = await _db!.getLastConnectedDeviceId();
        } catch (e) {
          print('Error getting last device ID: $e');
        }
      }

      // Bluetooth'u açmak için uygun bir yöntem kullanmalıyız.
      if (lastDeviceId != null) {
        await connectToDevice(lastDeviceId);
      } else {
        startScanning(); // Dönüş değerini kullanmıyorum.
      }
    } catch (e) {
      Get.snackbar('Bilgi',
          'Bluetooth otomatik başlatılamadı. Cihaz taraması yapabilirsiniz.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3));
    }
  }

  // Cihaz tarama
  Future<void> startScanning() async {
    if (isScanning.value) return;

    try {
      isScanning.value = true;

      // Bluetooth taramasını başlat
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

      // Tarama sonuçlarını dinle
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name.contains('SCALE')) {
            connectToDevice(r.device.id.toString());
          }
        }
      });
    } catch (e) {
      Get.snackbar(
          'Bilgi', 'Cihaz taraması başlatılamadı. Demo mod kullanılıyor.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3));

      // Demo cihaz bağlantısı simüle edilsin
      await Future.delayed(Duration(seconds: 2));
      isConnected.value = true;
      deviceName.value = 'Demo Tartı Cihazı';
      deviceStatus.value = 'Demo Bağlantı (Simülasyon)';
      startWeightListener();
    } finally {
      isScanning.value = false;
    }
  }

  // Cihaza bağlanma
  Future<void> connectToDevice(String deviceId) async {
    try {
      deviceStatus.value = 'Bağlanıyor...';

      // Cihaza bağlan
      // Not: Gerçek implementasyonda bu kısım cihaza özgü olacaktır
      await Future.delayed(Duration(seconds: 2)); // Simülasyon

      isConnected.value = true;
      Get.snackbar('Başarılı', 'Cihaza bağlandınız');
      deviceName.value = 'Tartı Cihazı';
      deviceStatus.value = 'Bağlı';

      // Cihaz ID'sini kaydet
      if (_dbConnected.value && _db != null) {
        try {
          await _db!.saveLastConnectedDeviceId(deviceId);
        } catch (e) {
          print('Error saving device ID: $e');
        }
      }

      startWeightListener();
    } catch (e) {
      Get.snackbar('Bilgi', 'Cihaza bağlanılamadı. Demo mod kullanılıyor.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3));
      deviceStatus.value = 'Demo Mod';

      // Demo bağlantı
      isConnected.value = true;
      deviceName.value = 'Demo Tartı Cihazı';
      startWeightListener();
    }
  }

  // Tartım dinleyicisi
  void startWeightListener() {
    // Gerçek implementasyonda burada cihazdan gelen verileri dinleyeceğiz
    // Şimdilik simüle ediyoruz
    Future.delayed(Duration(seconds: 1), () {
      if (isConnected.value) {
        // Simüle edilmiş rastgele ağırlık değerleri
        final baseWeight = 350.0;
        final randomVariation =
            DateTime.now().millisecondsSinceEpoch % 100 / 10;
        currentWeight.value = baseWeight + randomVariation;

        if (isWeighing.value) {
          processWeight(currentWeight.value);
        }

        // Sürekli güncellemek için tekrar çağır
        if (isConnected.value) {
          Future.delayed(Duration(seconds: 3), startWeightListener);
        }
      }
    });
  }

  // Ağırlık işleme
  void processWeight(double weight) async {
    if (!isWeighing.value) return;

    try {
      // Ayırma kurallarını kontrol et
      var rule = findMatchingRule(weight);

      // Tartım verisini kaydet
      Map<String, dynamic> weightRecord = {
        'weight': weight,
        'timestamp': DateTime.now().toIso8601String(),
        'deviceId': connectedDevice?.id.toString() ?? 'demo-device',
        'ruleApplied': rule?['name'],
        'category': rule?['category'],
      };

      if (_dbConnected.value && _db != null) {
        try {
          await _db!.saveWeightRecord(weightRecord);
        } catch (e) {
          print('Error saving weight record: $e');
        }
      }

      weightData.add(weightRecord);

      // İstatistikleri güncelle
      updateStats();
    } catch (e) {
      print('Error processing weight: $e');
    }
  }

  // Ayırma kuralı bulma
  Map<String, dynamic>? findMatchingRule(double weight) {
    return separationRules.firstWhereOrNull((rule) {
      double minWeight = rule['minWeight'] ?? 0;
      double maxWeight = rule['maxWeight'] ?? double.infinity;
      return weight >= minWeight && weight <= maxWeight;
    });
  }

  // Ayırma kurallarını yükleme
  Future<void> loadSeparationRules() async {
    if (!_dbConnected.value || _db == null) {
      _loadSampleData();
      return;
    }

    try {
      var rules = await _db!.getSeparationRules();
      separationRules.assignAll(rules);
    } catch (e) {
      print('Ayırma kuralları yüklenemedi: $e');
      _loadSampleData();
    }
  }

  // İstatistikleri yükleme
  Future<void> loadStats() async {
    if (!_dbConnected.value || _db == null) {
      return;
    }

    try {
      var savedStats = await _db!.getWeightingStats();
      Map<String, Object> convertedStats = {
        'totalWeighings': savedStats['totalWeighings'] as int? ?? 0,
        'errorRate': savedStats['errorRate'] as double? ?? 0.0,
        'lastSync': savedStats['lastSync'] != null
            ? DateTime.parse(savedStats['lastSync'] as String)
            : DateTime.now(),
      };
      stats.assignAll(convertedStats);
    } catch (e) {
      print('İstatistikler yüklenemedi: $e');
    }
  }

  // İstatistikleri güncelleme
  Future<void> updateStats() async {
    try {
      final newStats = <String, Object>{
        'totalWeighings': weightData.length,
        'errorRate': calculateErrorRate(),
        'lastSync': DateTime.now(),
      };
      stats.assignAll(newStats);

      if (_dbConnected.value && _db != null) {
        try {
          await _db!.saveWeightingStats(newStats);
        } catch (e) {
          print('Error saving weight stats: $e');
        }
      }
    } catch (e) {
      print('İstatistikler güncellenemedi: $e');
    }
  }

  // Hata oranı hesaplama
  double calculateErrorRate() {
    if (weightData.isEmpty) return 0.0;
    int errorCount = weightData
        .where((record) =>
            record['weight'] as double < 100 ||
            record['weight'] as double > 1000)
        .length;
    return (errorCount / weightData.length) * 100;
  }

  // Tartımı başlat/durdur
  void toggleWeighing() {
    isWeighing.value = !isWeighing.value;
    if (isWeighing.value) {
      startWeightListener();
    }
  }

  // Bağlantıyı kes
  void disconnect() {
    isConnected.value = false;
    deviceName.value = '';
    deviceStatus.value = 'Bağlı Değil';
    connectedDevice?.disconnect();
    connectedDevice = null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
