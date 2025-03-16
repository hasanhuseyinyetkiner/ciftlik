import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'AnimalGroupController.dart';

class AnimalGroupCard extends StatelessWidget {
  final AnimalGroup group;
  final AnimalGroupController controller = Get.find();

  AnimalGroupCard({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(group),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeGroup(group.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            borderRadius: BorderRadius.circular(15.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2.0,
            shadowColor: Colors.cyan,
            margin: const EdgeInsets.only(bottom: 10.0, right: 5, left: 5),
            child: ListTile(
              leading: Image.asset(
                'icons/sheep_and_cow_side_by_side_icon.png', // Buraya asset yolunu koyun
                width: 40.0, // İstenilen genişliği belirleyin
                height: 40.0, // İstenilen yüksekliği belirleyin
              ),              title: Text(
                'Grup Adı: ${group.groupName.isNotEmpty ? group.groupName : 'Bilinmiyor'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Positioned(
            top: 9,
            right: 16,
            child: Icon(
              Icons.swipe_left,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
