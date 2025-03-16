import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../FormFields/BuildDateField.dart';
import '../../../FormFields/BuildTimeField.dart';
import '../../../FormFields/BuildTextField.dart';
import '../../../FormFields/BuildCounterField.dart';
import '../../../FormUtils/FormUtils.dart';
import '../../../AnimalService/BuildSelectionSpeciesField.dart';
import '../../../FormFields/FormButton.dart';
import '../../../FormFields/WeightField.dart';
import 'AddSheepController.dart';

class AddSheepPage extends StatelessWidget {
  final AddSheepController controller = Get.put(AddSheepController());
  final FormUtils utils = FormUtils();

  AddSheepPage({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Koyununuzun bilgilerini giriniz.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const WeightField(),
            const SizedBox(height: 16),
            BuildTextField(
              label: 'Küpe No *',
              hint: 'GEÇİCİ_NO_16032',
              controller: controller.tagNoController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Küpe No boş bırakılamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            BuildTextField(
              label: 'Devlet Küpe No *',
              hint: 'GEÇİCİ_NO_16032',
              controller: controller.govTagNoController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Devlet Küpe No boş bırakılamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            BuildSelectionSpeciesField(
              label: 'Irk *',
              value: controller.selectedSheep,
              options: controller.species,
              onSelected: (value) {
                var selectedSpecies = controller.species.firstWhere(
                    (element) => element['animalsubtypename'] == value);
                controller.selectedSheep.value = value;
                controller.selectedSheepId.value = selectedSpecies['id'];
              },
            ),
            const SizedBox(height: 16),
            BuildTextField(
              label: 'Hayvan Adı',
              hint: '',
              controller: controller.nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Hayvan Adı boş bırakılamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            BuildCounterField(
              label: 'Koyun Tipi',
              controller: controller.countController,
              title: 'koyun',
            ),
            const SizedBox(height: 16),
            BuildDateField(
              label: 'Koyunun Kayıt Tarihi *',
              controller: controller.dobController,
            ),
            const SizedBox(height: 16),
            BuildTimeField(
              label: 'Koyunun Kayıt Zamanı',
              controller: controller.timeController,
              onTap: utils.showTimePicker,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
              child: FormButton(
                title: 'Kaydet',
                onPressed: controller.saveSheepData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
