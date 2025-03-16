import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../HayvanDetaySayfasi/AnimalDetailPage.dart';
import 'AnimalController.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final String tableName;

  const AnimalCard({Key? key, required this.animal, required this.tableName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnimalController controller = Get.find();

    return Slidable(
      key: ValueKey(animal.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) async {
              await controller.removeAnimal(animal.id, animal.tagNo!);
              Get.snackbar('Başarılı', 'Hayvan silindi');
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
      child: SingleChildScrollView(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                if (animal.tagNo != null) {
                  String? detailTableName =
                      await controller.getAnimalTable(animal.tagNo!);
                  if (detailTableName != null) {
                    print('Detail Table Name: $detailTableName');
                    var result = await Get.to(
                        () => AnimalDetailPage(
                            tableName: detailTableName, animalId: animal.id),
                        duration: const Duration(milliseconds: 650));
                    if (result != null) {
                      controller.updateAnimal(
                          animal.id, detailTableName, result);
                    }
                  } else {
                    Get.snackbar('Hata', 'Hayvan bulunamadı');
                  }
                } else {
                  Get.snackbar('Hata', 'Tag No bulunamadı');
                }
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                shadowColor: Colors.cyan,
                margin: const EdgeInsets.only(bottom: 10.0, right: 5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'icons/sheep_and_lamb_icon_black.png',
                          width: 55,
                          height: 55,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Küpe No: ${animal.tagNo}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4.0),
                            Text(animal.name ?? ''),
                            const SizedBox(height: 4.0),
                            Text(animal.dob ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 10,
              right: 20,
              child: Icon(
                Icons.swipe_left,
                size: 18,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
