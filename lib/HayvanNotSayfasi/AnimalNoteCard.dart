import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'AnimalNoteController.dart';

class AnimalNoteCard extends StatelessWidget {
  final AnimalNote note;
  final AnimalNoteController controller = Get.find();

  AnimalNoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(note),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeNote(note.id);
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
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2.0,
            shadowColor: Colors.cyan,
            margin: const EdgeInsets.only(bottom: 10.0, right: 10),
            child: ListTile(
              leading: Image.asset(
                'icons/notes_icon_black.png', // Buraya asset yolunu koyun
                width: 30.0, // İstenilen genişliği belirleyin
                height: 30.0, // İstenilen yüksekliği belirleyin
              ),              title: Text(note.date.isNotEmpty ? note.date : 'Bilinmiyor'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.notes.isNotEmpty ? note.notes : 'Bilinmiyor'),
                ],
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
