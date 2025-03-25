import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Notification status tracking
  final RxBool _hasPermission = false.obs;
  bool get hasPermission => _hasPermission.value;

  // Constructor
  NotificationService(this._notificationsPlugin) {
    _requestPermissions();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // For Android, directly check requestNotificationPermissions or set default permission
        _hasPermission.value = true; // Default for older Android versions
      }
    } catch (e) {
      print('Bildirim izinleri alınırken hata: $e');
      _hasPermission.value = false;
    }
  }

  // Show weight measurement notification
  Future<void> showWeightMeasurementNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weight_channel',
      'Tartım Bildirimleri',
      channelDescription: 'Tartım işlemleri ile ilgili bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // notification id
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show connectivity notification
  Future<void> showConnectivityNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'connectivity_channel',
      'Bağlantı Bildirimleri',
      channelDescription:
          'Bluetooth ve internet bağlantısı ile ilgili bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      1, // notification id
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show sync notification
  Future<void> showSyncNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sync_channel',
      'Senkronizasyon Bildirimleri',
      channelDescription: 'Veri senkronizasyonu ile ilgili bildirimler',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2, // notification id
      title,
      body,
      details,
      payload: payload,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _initializeTimeZones();
  }

  void _initializeTimeZones() {
    try {
      tz_data.initializeTimeZones();
    } catch (e) {
      print('Error initializing timezones: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ciftlik_yonetim_channel',
      'Çiftlik Yönetim Bildirimleri',
      channelDescription: 'Çiftlik yönetim sistemi için bildirimler',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> showWeightNotification(double weight, bool isStable) async {
    final title = isStable ? 'Ölçüm Tamamlandı' : 'Ölçüm Yapıldı (Kararsız)';

    final body = isStable
        ? 'Kararlı ölçüm kaydedildi: ${weight.toStringAsFixed(1)} kg'
        : 'Ölçüm kaydedildi: ${weight.toStringAsFixed(1)} kg (kararsız)';

    await showNotification(
      title: title,
      body: body,
      payload: 'weight_measurement',
    );
  }

  Future<void> showConnectivityChangeNotification(bool isOnline) async {
    if (isOnline) {
      await showNotification(
        title: 'Bağlantı Sağlandı',
        body: 'İnternet bağlantısı kuruldu. Veriler senkronize edilebilir.',
        payload: 'connectivity_change',
      );
    } else {
      await showNotification(
        title: 'Bağlantı Kesildi',
        body: 'İnternet bağlantısı kesildi. Veriler yerel olarak saklanacak.',
        payload: 'connectivity_change',
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
