import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FormFields/BuildNumberField.dart';
import '../FormFields/BuildSelectionField.dart';
import '../FormFields/FormButton.dart';
import 'BuildTextFeedField.dart';
import 'FeedController.dart';
import 'FeedDetailEditController.dart';

class FeedDetailEditPage extends StatelessWidget {
  final FeedDetailEditController controller =
      Get.put(FeedDetailEditController());
  final int feedId;
  final FeedController feedController = Get.find(); // FeedController'ı bulun

  FeedDetailEditPage({super.key, required this.feedId}) {
    controller.loadFeedDetails(feedId);
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
              const SizedBox(height: 16),
              BuildTextFeedField(
                label: 'Yem Adı',
                controller: controller.yemAdiController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Kuru Madde (%)',
                controller: controller.kuruMaddeController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'UFL (kg başına)',
                controller: controller.uflController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Metabolizable Enerji, ME (kcal/kg)',
                controller: controller.meController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'PDI (g/kg)',
                controller: controller.pdiController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Ham Protein CP (%)',
                controller: controller.hamProteinController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Lizin (%/PDI)',
                controller: controller.lizinController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Metionin (%/PDI)',
                controller: controller.metioninController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Kalsiyum abs (g/kg)',
                controller: controller.kalsiyumController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Fosfor abs (g/kg)',
                controller: controller.fosforController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Alt Limit (kg)',
                controller: controller.altLimitController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildNumberField(
                label: 'Üst Limit (kg)',
                controller: controller.ustLimitController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildTextFeedField(
                label: 'Notlar',
                controller: controller.notlarController,
                hint: '',
              ),
              const SizedBox(height: 16),
              BuildSelectionField(
                label: 'Tür',
                value: controller.selectedTur,
                options: const [
                  'Kaba Yem',
                  'Konsantre Yem',
                  'Diğer'
                ], // Gerçek seçeneklerle güncelleyin
                onSelected: (value) {
                  controller.selectedTur.value = value;
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                child: FormButton(
                  title: 'Güncelle',
                  onPressed: () async {
                    if (controller.formKey.currentState!.validate()) {
                      controller.updateFeedDetails(feedId);
                      feedController
                          .fetchFeedStocks(); // Feed listesi güncelleniyor
                      Get.back(result: true);
                      Get.snackbar('Başarılı', 'Yem Stoğu Güncellendi',
                          duration: const Duration(milliseconds: 1800));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
