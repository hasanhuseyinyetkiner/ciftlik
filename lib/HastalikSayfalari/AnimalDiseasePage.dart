import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AddAnimalDiseasePage.dart';
import 'AnimalDiseaseController.dart';
import 'AnimalDiseaseCard.dart';

class AnimalDiseasePage extends StatefulWidget {
  final String tagNo;

  const AnimalDiseasePage({Key? key, required this.tagNo}) : super(key: key);

  @override
  _AnimalDiseasePageState createState() => _AnimalDiseasePageState();
}

class _AnimalDiseasePageState extends State<AnimalDiseasePage> {
  final AnimalDiseaseController controller = Get.put(AnimalDiseaseController());

  @override
  void initState() {
    super.initState();
    controller.fetchDiseasesByTagNo(widget.tagNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
          child: Container(
            height: 40,
            width: 130,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('resimler/Merlab.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
            onPressed: () {
              Get.dialog(AddAnimalDiseasePage(tagNo: widget.tagNo));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            if (controller.diseases.isEmpty) {
              return const Center(
                child: Text(
                  'Hastalık kaydı bulunamadı',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: controller.diseases.length,
                itemBuilder: (context, index) {
                  final disease = controller.diseases[index];
                  return AnimalDiseaseCard(disease: disease);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
