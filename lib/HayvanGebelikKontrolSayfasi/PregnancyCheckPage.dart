import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AddPregnancyCheckPage.dart';
import 'PregnancyCheckController.dart';
import 'PregnancyCheckCard.dart';

class PregnancyCheckPage extends StatefulWidget {
  final String tagNo;

  const PregnancyCheckPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  _PregnancyCheckPageState createState() => _PregnancyCheckPageState();
}

class _PregnancyCheckPageState extends State<PregnancyCheckPage> {
  final PregnancyCheckController controller =
      Get.put(PregnancyCheckController());

  @override
  void initState() {
    super.initState();
    controller.fetchKontrolsByTagNo(widget.tagNo);
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
              Get.dialog(AddPregnancyCheckPage(tagNo: widget.tagNo));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            if (controller.kontrols.isEmpty) {
              return const Center(
                child: Text(
                  'Gebelik kontrol kaydı bulunamadı',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: controller.kontrols.length,
                itemBuilder: (context, index) {
                  final kontrol = controller.kontrols[index];
                  return PregnancyCheckCard(kontrol: kontrol);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
