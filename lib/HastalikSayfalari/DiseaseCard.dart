import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'DiseaseController.dart';

class DiseaseCard extends StatefulWidget {
  final Disease disease;

  const DiseaseCard({Key? key, required this.disease}) : super(key: key);

  @override
  _DiseaseCardState createState() => _DiseaseCardState();
}

class _DiseaseCardState extends State<DiseaseCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final DiseaseController controller = Get.find<DiseaseController>();

    return Slidable(
      key: ValueKey(widget.disease),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              //controller.removeDisease(widget.disease);
              Get.snackbar('Başarılı', 'Hastalık silindi');
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
            elevation: 4.0,
            shadowColor: Colors.cyan,
            margin: const EdgeInsets.only(bottom: 10.0, right: 5),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                onExpansionChanged:
                    (bool expanding) => setState(() => isExpanded = expanding),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/images/login_screen_2.png',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(widget.disease.diseaseName),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                childrenPadding: const EdgeInsets.all(8.0),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset(
                      'assets/images/login_screen_2.png',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(widget.disease.diseaseDescription),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 2,
            right: 10,
            child: Icon(Icons.swipe_left, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
