import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

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

  @override
  void onClose() {
    subscription?.cancel();
    _stateListener?.cancel();
    _timer.cancel();
    scanSubscription?.cancel();
    scanTimer.cancel();
    scanUpdateTimer.cancel();
    super.onClose();
  }
}
