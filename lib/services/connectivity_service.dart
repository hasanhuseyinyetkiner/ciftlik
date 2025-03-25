import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../services/data_service.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends GetxService {
  // Dependencies
  final NotificationService? _notificationService =
      Get.find<NotificationService>();
  final Connectivity _connectivity = Connectivity();

  // Observable states
  final RxBool _isConnected = false.obs;
  final Rx<ConnectivityResult> _connectionType = ConnectivityResult.none.obs;

  // Public getters
  bool get isConnected => _isConnected.value;
  ConnectivityResult get connectionType => _connectionType.value;

  // Constructor & initialization
  ConnectivityService() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  // Initialize connectivity check
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // Handle the result from connectivity check
      _processConnectivityResult(result);
    } catch (e) {
      print('Bağlantı kontrolü yapılırken hata oluştu: $e');
      _isConnected.value = false;
      _connectionType.value = ConnectivityResult.none;
    }
  }

  // Listen for connectivity changes
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      // Process connectivity result
      _processConnectivityResult(result);
    });
  }

  // Process connectivity result which can be either a single result or a list
  void _processConnectivityResult(dynamic result) {
    // Convert to proper ConnectivityResult
    ConnectivityResult connectivityResult;

    if (result is List<ConnectivityResult> && result.isNotEmpty) {
      // If result is a list (newer versions of connectivity_plus), take the first item
      connectivityResult = result.first;
    } else if (result is ConnectivityResult) {
      // If result is already a ConnectivityResult, use it directly
      connectivityResult = result;
    } else {
      // Fallback to none if unexpected type
      connectivityResult = ConnectivityResult.none;
    }

    // Update connection status with the processed result
    _updateConnectionStatus(connectivityResult);
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionType.value = result;

    // Update connected status based on connection type
    final wasConnected = _isConnected.value;
    _isConnected.value = (result != ConnectivityResult.none);

    // Send notification on connection change
    if (wasConnected != _isConnected.value) {
      _sendConnectivityNotification();
    }
  }

  // Send a notification about connectivity change
  void _sendConnectivityNotification() {
    if (_notificationService == null) return;

    final title = _isConnected.value ? 'Bağlantı Kuruldu' : 'Bağlantı Kesildi';

    final body = _isConnected.value
        ? 'İnternet bağlantısı kuruldu: ${_getConnectionTypeName()}'
        : 'İnternet bağlantısı kesildi. Veriler çevrimdışı kaydediliyor.';

    _notificationService?.showConnectivityNotification(
      title: title,
      body: body,
    );
  }

  // Get user-friendly connection type name
  String _getConnectionTypeName() {
    switch (_connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobil Veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      default:
        return 'Bilinmeyen';
    }
  }

  // Check if device has a specific connection type
  bool hasWifi() => _connectionType.value == ConnectivityResult.wifi;
  bool hasMobile() => _connectionType.value == ConnectivityResult.mobile;
  bool hasEthernet() => _connectionType.value == ConnectivityResult.ethernet;
  bool hasBluetooth() => _connectionType.value == ConnectivityResult.bluetooth;

  // Force a manual connectivity check
  Future<void> checkConnectivity() async {
    await _initConnectivity();
  }

  Future<void> syncDataIfOnline() async {
    if (!isConnected) {
      Get.snackbar(
        'Senkronizasyon Hatası',
        'İnternet bağlantısı olmadan veriler senkronize edilemez.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Find the data service and trigger sync
    if (Get.isRegistered<DataService>()) {
      try {
        final dataService = Get.find<DataService>();
        final success = await dataService.syncDataWithSupabase();

        Get.snackbar(
          success ? 'Senkronizasyon Başarılı' : 'Senkronizasyon Hatası',
          success
              ? 'Veriler başarıyla senkronize edildi.'
              : 'Veri senkronizasyonunda hata oluştu.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        print('Error syncing data: $e');
        Get.snackbar(
          'Senkronizasyon Hatası',
          'Veri senkronizasyonunda hata oluştu: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
