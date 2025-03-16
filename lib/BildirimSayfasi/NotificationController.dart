import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;

  void fetchNotifications() async {
    // Bildirim verilerini veritabanından veya API'den çekme işlemi
    var notificationData = [
      AppNotification(id: 1, title: 'Yeni Mesaj', content: 'Mesaj içeriği 1'),
      AppNotification(id: 2, title: 'Güncelleme', content: 'Yeni güncelleme mevcut'),
    ];
    notifications.assignAll(notificationData);
  }

  void removeNotification(int id) {
    notifications.removeWhere((notification) => notification.id == id);
    Get.snackbar('Başarılı', 'Bildirim silindi');
  }
}

class AppNotification {
  final int id;
  final String title;
  final String content;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
  });
}
