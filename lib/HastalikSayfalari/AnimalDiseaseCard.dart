import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'AnimalDiseaseController.dart';

class AnimalDiseaseCard extends StatelessWidget {
  final Disease disease;
  final AnimalDiseaseController controller = Get.find();

  AnimalDiseaseCard({Key? key, required this.disease}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(disease),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeDisease(disease.id);
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
                'icons/sheep_with_illness_icon_black.png', // Buraya asset yolunu koyun
                width: 40.0, // İstenilen genişliği belirleyin
                height: 40.0, // İstenilen yüksekliği belirleyin
              ),              title: Text(disease.date),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(disease.diseaseName ?? 'Bilinmiyor'), // Null kontrolü
                  Text(disease.notes),
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
