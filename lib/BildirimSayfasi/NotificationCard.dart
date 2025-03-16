import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'NotificationController.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final NotificationController controller = Get.find();

  NotificationCard({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(notification),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeNotification(notification.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            borderRadius: BorderRadius.circular(12.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        shadowColor: Colors.cyan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4.0,
        margin: const EdgeInsets.only(bottom: 10.0, right: 10),
        child: ListTile(
          leading: const Icon(Icons.notifications, size: 40.0,color: Colors.black,),
          title: Text(notification.title),
          subtitle: Text(notification.content),
        ),
      ),
    );
  }
}
