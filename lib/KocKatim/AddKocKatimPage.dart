import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FormFields/FormButton.dart';
import '../../FormFields/BuildDateField.dart';
import '../../FormFields/BuildTimeField.dart';
import 'AddKocKatimController.dart';
import 'BuildSelectionKocKatimField.dart';

class AddKocKatimPage extends StatelessWidget {
  final AddKocKatimController controller = Get.put(AddKocKatimController());

  AddKocKatimPage({super.key});

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
            controller.resetForm();
            Get.back();
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Koyun ve koçunuzu seçerek eşleme yapınız.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              BuildSelectionKocKatimField(
                label: 'Koyununuz *',
                value: controller.selectedKoyun,
                options: controller.koyun,
                onSelected: (tagNo, name) {
                  controller.selectedKoyun.value =
                      tagNo; // Koyunun tagNo'sunu kaydet
                  controller.selectedKoyunAdi.value =
                      name; // Koyunun adını kaydet
                },
              ),
              const SizedBox(height: 16),
              BuildSelectionKocKatimField(
                label: 'Koçunuz *',
                value: controller.selectedKoc,
                options: controller.koc,
                onSelected: (tagNo, name) {
                  controller.selectedKoc.value =
                      tagNo; // Koçun tagNo'sunu kaydet
                  controller.selectedKocAdi.value = name; // Koçun adını kaydet
                },
              ),
              const SizedBox(height: 16),
              BuildDateField(
                label: 'Tarih',
                controller: controller.dateController,
              ),
              const SizedBox(height: 16),
              BuildTimeField(
                label: 'Saat',
                controller: controller.timeController,
                onTap: (BuildContext context,
                    TextEditingController controller) async {
                  await _selectTime(context, controller);
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                child: FormButton(
                  title: 'Kaydet',
                  onPressed: controller.saveKocKatimData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
    }
  }
}
