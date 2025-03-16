import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AddAnimalWeightPage.dart';
import 'AnimalWeightCard.dart';
import 'AnimalWeightDetailCard.dart';
import 'DatabaseAddAnimalWeightHelper.dart';
import 'ExcelHelper.dart'; // ExcelHelper dosyasını dahil edin
import 'AnimalWeightController.dart';

class AnimalWeightPage extends StatefulWidget {
  final int animalId;

  const AnimalWeightPage({Key? key, required this.animalId}) : super(key: key);

  @override
  _AnimalWeightPageState createState() => _AnimalWeightPageState();
}

class _AnimalWeightPageState extends State<AnimalWeightPage> {
  final AnimalWeightController controller = Get.put(AnimalWeightController());
  String? tagNo;

  @override
  void initState() {
    super.initState();
    controller.fetchWeightsByAnimalId(widget.animalId);
    _getTagNo(); // TagNo bilgisini al
  }

  void _getTagNo() async {
    var weightDetails = await DatabaseAddAnimalWeightHelper.instance
        .getAnimalWeightDetails(widget.animalId);
    if (weightDetails != null && weightDetails.containsKey('tagNo')) {
      setState(() {
        tagNo = weightDetails['tagNo'];
      });
    }
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
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0),
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: tagNo != null
                ? () async {
                    await ExcelHelper.exportToExcel(
                        widget.animalId, controller.weights, tagNo!);
                  }
                : null, // TagNo varsa buton aktif
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
            onPressed: () {
              Get.dialog(AddAnimalWeightPage(animalId: widget.animalId));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimalWeightDetailCard(animalId: widget.animalId),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () {
                  if (controller.weights.isEmpty) {
                    return const Center(
                      child: Text(
                        'Ağırlık kaydı bulunamadı',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: controller.weights.length,
                      itemBuilder: (context, index) {
                        final weight = controller.weights[index];
                        return AnimalWeightCard(weight: weight);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
