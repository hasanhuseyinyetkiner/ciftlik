import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock notification data
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Aşı Hatırlatıcı',
      message: 'Bugün 5 hayvan için aşı zamanı geldi.',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.vaccine,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Süt Üretimi',
      message: 'Dünün süt üretimi 1,250 litre olarak kaydedildi.',
      dateTime: DateTime.now().subtract(const Duration(hours: 12)),
      type: NotificationType.milk,
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Sağlık Uyarısı',
      message: '2 hayvan için sağlık kontrolü planlanmalı.',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.health,
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Yem Stok Uyarısı',
      message: 'Yem stoku %20\'nin altına düştü. Sipariş vermeyi düşünün.',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.feed,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Doğum Bildirimi',
      message: 'Yeni bir buzağı doğumu gerçekleşti. Kayıt için tıklayın.',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.birth,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Tümünü okundu işaretle',
          ),
        ],
      ),
      body: OverflowHandler(
        child: _notifications.isEmpty
            ? _buildEmptyState(theme)
            : _buildNotificationList(theme),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Bildiriminiz Yok',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimleriniz burada görünecek',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification, theme);
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, ThemeData theme) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((item) => item.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bildirim silindi'),
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () {
                setState(() {
                  _notifications.insert(
                      _notifications.length > 0 ? 1 : 0, notification);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: notification.isRead
            ? null
            : theme.colorScheme.primary.withOpacity(0.05),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification.type, theme)
                .withOpacity(0.2),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type, theme),
            ),
          ),
          title: Text(
            notification.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(notification.dateTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
          onTap: () => _markAsRead(notification),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.vaccine:
        return Icons.medical_services;
      case NotificationType.milk:
        return Icons.water_drop;
      case NotificationType.health:
        return Icons.local_hospital;
      case NotificationType.feed:
        return Icons.restaurant;
      case NotificationType.birth:
        return Icons.child_care;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type, ThemeData theme) {
    switch (type) {
      case NotificationType.vaccine:
        return Colors.orange;
      case NotificationType.milk:
        return Colors.blue;
      case NotificationType.health:
        return Colors.red;
      case NotificationType.feed:
        return Colors.green;
      case NotificationType.birth:
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexWhere((item) => item.id == notification.id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm bildirimler okundu olarak işaretlendi'),
      ),
    );
  }
}

enum NotificationType {
  vaccine,
  milk,
  health,
  feed,
  birth,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? dateTime,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}