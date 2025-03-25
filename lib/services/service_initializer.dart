import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'connectivity_service.dart';
import '../TartimModulu/AutoWeightController.dart';

class ServiceInitializer {
  static Future<void> initializeServices() async {
    // Initialize flutter_local_notifications plugin
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Register core services
    final dbService = Get.put<DatabaseService>(DatabaseService());
    await dbService.init();

    // Register notification service with plugin
    final notificationService = Get.put<NotificationService>(
      NotificationService(flutterLocalNotificationsPlugin),
    );

    // Register connectivity service
    final connectivityService =
        Get.put<ConnectivityService>(ConnectivityService());

    // Register controllers
    Get.lazyPut(() => AutoWeightController(), fenix: true);

    debugPrint("All services initialized successfully");
  }
}
