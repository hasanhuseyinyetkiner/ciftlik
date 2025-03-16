import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'PregnancyCheckController.dart';

class PregnancyCheckCard extends StatelessWidget {
  final Kontrol kontrol;
  final PregnancyCheckController controller = Get.put(PregnancyCheckController());

  PregnancyCheckCard({Key? key, required this.kontrol}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(kontrol),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeKontrol(kontrol.id);
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
                kontrol.kontrolSonucu == 'Gebe'
                    ? 'icons/cow_check_with_magnifying_glass_icon.png'
                    : 'icons/cow_crossed_out_with_magnifying_glass_icon.png',
                width: 50.0, // İstenilen genişliği belirleyin
                height: 50.0, // İstenilen yüksekliği belirleyin
              ),
              title: Text(kontrol.date),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kontrol.kontrolSonucu ?? 'Bilinmiyor'),
                  Text(kontrol.notes),
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
