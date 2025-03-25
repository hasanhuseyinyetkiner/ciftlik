import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../services/data_service.dart';

class BleController extends GetxController {
  var scanResults = <ScanResult>[].obs;
  var isScanning = false.obs;
  var isBluetoothEnabled = false.obs;
  var isSwitchLocked = false.obs;
  var sayac = 0.obs;
  var deviceState = BluetoothConnectionState.disconnected.obs;
  var bluetoothServices = <BluetoothService>[].obs;
  var notifyDatas = <String, List<int>>{}.obs;
  var connectedDevice = Rx<BluetoothDevice?>(null);
  StreamSubscription<BluetoothAdapterState>? subscription;
  StreamSubscription<BluetoothConnectionState>? _stateListener;
  StreamSubscription<List<ScanResult>>? scanSubscription;
  late Timer _timer;
  late Timer scanTimer;
  late Timer scanUpdateTimer;

  // Data service for synchronization
  final DataService _dataService = Get.find<DataService>();

  // Track received data
  var receivedData = <Map<String, dynamic>>[].obs;
  var isDataSynced = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkBluetoothSupportAndListenState();
    startPrintTimer();
    startScanUpdateTimer();
  }

  void startPrintTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      print('isScanning: ${isScanning.value}');
    });
  }

  void startScanUpdateTimer() {
    scanUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      scanResults.refresh();
    });
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device
          .connect(autoConnect: false)
          .timeout(const Duration(minutes: 1));
      await device.requestMtu(260);
      await discoverServices(device);
      stopScan();
      connectedDevice.value = device; // Bağlı cihazı kaydet
      listenToDeviceState(device); // Cihaz durumunu dinle
      return true;
    } catch (e) {
      Get.snackbar('Bağlantı Hatası', 'Cihaza bağlanılamadı: $e');
      print('Connection error: $e');
      return false;
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    bluetoothServices.value = await device.discoverServices();
  }

  void listenToDeviceState(BluetoothDevice device) {
    _stateListener = device.connectionState.listen((state) {
      deviceState.value = state;
      if (state == BluetoothConnectionState.disconnected) {
        Get.snackbar('Bağlantı Kesildi', 'Cihaz bağlantısı kesildi.');
        connectedDevice.value = null;
      }
    });
  }

  void startScan() {
    scanResults.clear();
    isScanning.value = true;
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      scanResults.assignAll(results.take(20));
      sayac.value =
          scanResults.where((result) => result.device.name.isNotEmpty).length;
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 60)).then((_) {
      if (isScanning.value) {
        restartScan();
      } else {
        isScanning.value = false;
        Get.snackbar(
            'Tarama Tamamlandı', 'Bluetooth cihaz taraması tamamlandı.');
      }
    });
  }

  void restartScan() {
    scanTimer = Timer(const Duration(seconds: 5), () {
      if (isScanning.value) {
        startScan();
      }
    });
  }

  void disconnect() {
    if (connectedDevice.value != null) {
      connectedDevice.value!.disconnect();
      connectedDevice.value = null;
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan().then((_) {
      isScanning.value = false;
      scanResults.clear();
      sayac.value = 0;
      scanSubscription?.cancel();
      scanTimer.cancel();
      scanUpdateTimer.cancel();
    });
  }

  void checkBluetoothSupportAndListenState() async {
    if (await FlutterBluePlus.isAvailable == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    subscription = FlutterBluePlus.adapterState.listen((state) {
      isBluetoothEnabled.value = state == BluetoothAdapterState.on;
    });

    isBluetoothEnabled.value =
        await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  }

  // Save Bluetooth measurement data to database
  Future<bool> saveBluetoothMeasurement(
      Map<String, dynamic> measurementData) async {
    try {
      // Add timestamp if not provided
      if (!measurementData.containsKey('created_at')) {
        measurementData['created_at'] = DateTime.now().toIso8601String();
      }

      // Save to local database
      final success = await _dataService.saveData(
        apiEndpoint: 'BluetoothMeasurements',
        tableName: 'bluetooth_olcum',
        data: measurementData,
      );

      if (success) {
        // Add to received data list
        receivedData.add(measurementData);

        // Set synced flag to false to indicate need for sync
        isDataSynced.value = false;

        // Sync with Supabase if online
        if (_dataService.isUsingSupabase) {
          syncWithSupabase();
        }
      }

      return success;
    } catch (e) {
      print('Error saving Bluetooth measurement: $e');
      return false;
    }
  }

  // Sync data with Supabase
  Future<void> syncWithSupabase() async {
    if (!_dataService.isUsingSupabase || isDataSynced.value) return;

    try {
      final success = await _dataService.syncAfterUserInteraction(
        specificTables: ['bluetooth_olcum'],
      );

      if (success) {
        isDataSynced.value = true;
        print('Bluetooth data successfully synced with Supabase');
      }
    } catch (e) {
      print('Error syncing Bluetooth data: $e');
    }
  }

  // Process received data from BLE device
  void processReceivedData(List<int> data, String sourceId) async {
    try {
      // Process the bytes into meaningful data
      // This will vary based on your device protocol
      String dataString = String.fromCharCodes(data);
      print('Received from $sourceId: $dataString');

      // Example parsing - adjust based on your device protocol
      // Here we assume the data is in format "value:123.45"
      if (dataString.contains(':')) {
        final parts = dataString.split(':');
        final measurementType = parts[0].trim();
        final measurementValue = double.tryParse(parts[1].trim()) ?? 0.0;

        // Create measurement data object
        final measurementData = {
          'device_id': connectedDevice.value?.remoteId.str ?? 'unknown',
          'device_name': connectedDevice.value?.platformName ?? 'unknown',
          'measurement_type': measurementType,
          'measurement_value': measurementValue,
          'raw_data': dataString,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Save to database and sync
        await saveBluetoothMeasurement(measurementData);
      }
    } catch (e) {
      print('Error processing BLE data: $e');
    }
  }

  // Handle notify value for characteristic
  void setNotifyValue(
      BluetoothCharacteristic characteristic, bool enabled) async {
    try {
      await characteristic.setNotifyValue(enabled);

      if (enabled) {
        // Listen for notifications from this characteristic
        characteristic.onValueReceived.listen((data) {
          // Update the data for this characteristic
          notifyDatas[characteristic.characteristicUuid.toString()] = data;

          // Process the received data
          processReceivedData(
              data, characteristic.characteristicUuid.toString());
        });
      }
    } catch (e) {
      print('Error setting notify value: $e');
    }
  }

  @override
  void onClose() {
    _timer.cancel();
    scanTimer.cancel();
    scanUpdateTimer.cancel();
    subscription?.cancel();
    _stateListener?.cancel();
    scanSubscription?.cancel();

    // Sync any remaining data before closing
    if (!isDataSynced.value && _dataService.isUsingSupabase) {
      syncWithSupabase();
    }

    super.onClose();
  }
}
