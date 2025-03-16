import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AnimalGroupController.dart';
import 'AddAnimalGroupPage.dart';
import 'AnimalGroupCard.dart';

class AnimalGroupPage extends StatefulWidget {
  final String tagNo;

  const AnimalGroupPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  _AnimalGroupPageState createState() => _AnimalGroupPageState();
}

class _AnimalGroupPageState extends State<AnimalGroupPage> {
  final AnimalGroupController controller = Get.put(AnimalGroupController());

  @override
  void initState() {
    super.initState();
    controller.fetchGroupsByTagNo(widget.tagNo);
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
              Get.dialog(AddAnimalGroupPage(tagNo: widget.tagNo));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            if (controller.groups.isEmpty) {
              return const Center(
                child: Text(
                  'Grup kaydı bulunamadı',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center, // Yazıyı ortalar
                ),
              );
            } else {
              return ListView.builder(
                itemCount: controller.groups.length,
                itemBuilder: (context, index) {
                  final group = controller.groups[index];
                  return AnimalGroupCard(group: group);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
