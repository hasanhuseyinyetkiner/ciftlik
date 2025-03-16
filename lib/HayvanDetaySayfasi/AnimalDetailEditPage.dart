import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AnimalService/BuildSelectionAnimalField.dart';
import '../AnimalService/BuildSelectionLocationField.dart';
import '../AnimalService/BuildSelectionSpeciesField.dart';
import '../FormUtils/FormUtils.dart';
import 'AnimalDetailEditController.dart';

class AnimalDetailEditPage extends StatelessWidget {
  final AnimalDetailEditController controller =
      Get.put(AnimalDetailEditController());
  final FormUtils utils = FormUtils();
  final String tableName;
  final int animalId;

  AnimalDetailEditPage(
      {super.key, required this.tableName, required this.animalId}) {
    controller.loadAnimalDetails(tableName, animalId);
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
                  image: AssetImage('resimler/logo_v2.png'),
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
              // BuildTextField(
              //   label: 'Küpe No',
              //   controller: controller.tagNoController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              // BuildTextField(
              //   label: 'Ad',
              //   controller: controller.nameController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              // BuildDateField(
              //   label: 'Doğum Tarihi',
              //   controller: controller.dobController,
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Durum',
              //   value: controller.status,
              //   options: const ['Durum1', 'Durum2'],
              //   onSelected: (value) {
              //     controller.status.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildTextField(
              //   label: 'Kemer No',
              //   controller: controller.beltNoController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              // BuildTextField(
              //   label: 'Lak.no: 1 / 0 SGS',
              //   controller: controller.lakNoController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              // BuildTextField(
              //   label: 'Pedometre',
              //   controller: controller.pedometerController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              BuildSelectionSpeciesField(
                label: 'Irk',
                value: controller.speciesController,
                options: controller.speciesOptions,
                onSelected: (value) {
                  var selectedSpecies = controller.speciesOptions.firstWhere(
                      (element) => element['animalsubtypename'] == value);
                  controller.speciesController.value =
                      selectedSpecies['animalsubtypename'];
                },
              ),
              const SizedBox(height: 16),
              BuildSelectionLocationField(
                label: 'Lokasyon *',
                value: controller.location,
                options: controller.locations,
                onSelected: (value) {
                  controller.location.value = value;
                },
              ),
              const SizedBox(height: 16),
              // BuildTextField(
              //   label: 'Notlar',
              //   controller: controller.notesController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              BuildSelectionAnimalField(
                label: 'Ana ID',
                value: controller.motherController,
                options: controller.motherOptions,
                onSelected: (value) {
                  var selectedMother = controller.motherOptions
                      .firstWhere((element) => element['tagNo'] == value);
                  controller.motherController.value =
                      selectedMother['tagNo'].toString();
                },
              ),
              const SizedBox(height: 16),
              BuildSelectionAnimalField(
                label: 'Baba ID',
                value: controller.fatherController,
                options: controller.fatherOptions,
                onSelected: (value) {
                  var selectedFather = controller.fatherOptions
                      .firstWhere((element) => element['tagNo'] == value);
                  controller.fatherController.value =
                      selectedFather['tagNo'].toString();
                },
              ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Sürüde doğdu',
              //   value: controller.bornInHerdController,
              //   options: const ['Evet', 'Hayır'],
              //   onSelected: (value) {
              //     controller.bornInHerdController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Renk',
              //   value: controller.colorController,
              //   options: const ['Beyaz', 'Siyah'],
              //   onSelected: (value) {
              //     controller.colorController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Oluşma Şekli',
              //   value: controller.formationTypeController,
              //   options: const ['Suni Tohumlama', 'Doğal Aşım', 'Embriyo Transferi'],
              //   onSelected: (value) {
              //     controller.formationTypeController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Boynuz',
              //   value: controller.hornController,
              //   options: const ['Var', 'Yok'],
              //   onSelected: (value) {
              //     controller.hornController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Doğum Türü',
              //   value: controller.birthTypeController,
              //   options: const ['Normal', 'Sezaryen'],
              //   onSelected: (value) {
              //     controller.birthTypeController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Sigorta',
              //   value: controller.insuranceController,
              //   options: const ['Evet', 'Hayır'],
              //   onSelected: (value) {
              //     controller.insuranceController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'İkizlik',
              //   value: controller.twinsController,
              //   options: const ['Evet', 'Hayır'],
              //   onSelected: (value) {
              //     controller.twinsController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildSelectionField(
              //   label: 'Cinsiyet',
              //   value: controller.genderController,
              //   options: const ['Erkek', 'Dişi'],
              //   onSelected: (value) {
              //     controller.genderController.value = value;
              //   },
              // ),
              const SizedBox(height: 16),
              // BuildTextField(
              //   label: 'Devlet Küpe No',
              //   controller: controller.govTagNoController,
              //   hint: '',
              // ),
              const SizedBox(height: 16),
              // BuildTimeField(
              //   label: 'Doğum Saati',
              //   controller: controller.timeController,
              //   onTap: utils.showTimePicker,
              // ),
              const SizedBox(height: 16),
              // BuildCounterField(
              //   label: 'Hayvan Tipi Skoru',
              //   controller: controller.typeController,
              //   title: 'hayvan',
              // ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                child: buildFormButton(
                  title: 'Güncelle',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.updateAnimalDetails(tableName, animalId);
                      Get.back(result: true);
                      Get.snackbar('Başarılı', 'Güncelleme Kaydedildi',
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

  Widget buildFormButton(
      {required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
